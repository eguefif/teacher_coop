defmodule TeacherCoop.SearchEngineRepo do
  @moduledoc """
  This module is a layer between the Search Engine and the application.
  It handles indexing document and search.

   TODO: Should happend in a background job with retry. We want to make sure it happens
   Meilisearch indexes document asynchrounously, we need to check if it worked.
   Potential strategy:
   1. start trying indexing here
   2. Schedule a check job with task_details and retry mechanism
   3. Keep track in the document database to know if a document was indexed or in a table

   TODO: thing about the public interface, it might be too specialized with the data architecture
  """
  alias TeacherCoop.Library.Document
  alias TeacherCoop.Discovery.SearchResult
  alias TeacherCoop.Accounts.Scope

  @indexes ["documents", "documents_test"]

  @doc """
  Index a document in Meilisearch
  """
  def index_document(%Scope{} = scope, %Document{} = document) do
    attrs =
      Map.from_struct(document)
      |> Map.filter(&(elem(&1, 0) != :__meta__))
      |> Map.put(:email, scope.user.email)
      |> Map.put(:fullname, scope.user.fullname)

    case Meilisearch.Document.create_or_replace(get_client(), index_name("documents"), attrs) do
      {:ok, _task = %Meilisearch.SummarizedTask{taskUid: _taskUid}} -> :ok
      {:error, _error_details} -> :error
    end
  end

  @doc """
  Specialized function to look into documents
  """
  def search_document(search_terms) when is_bitstring(search_terms) do
    client = Meilisearch.client(:meilisearch)

    case Meilisearch.Search.search(client, "documents", q: search_terms) do
      {:ok, response} ->
        {:ok, create_search_result(response)}

      _ ->
        :error
    end
  end

  @doc """
  Initliazes all the indexes after dropping them.
  """
  def init_indexes() do
    IO.puts("Starting meilisearch operations for reset")
    drop_all(@indexes)
    IO.puts(" 1. Dropped all index")
    create_indexes(@indexes)
    IO.puts(" 2. Recreated index")
    IO.puts("Meilisearch end of operations")
  end

  @doc """
  Removes all index from Meilisearch
  """
  def drop_all(indexes) do
    client = get_client()

    tasks =
      indexes
      |> Enum.map(&{&1, Meilisearch.Index.get(client, &1)})
      |> Enum.reject(&(elem(elem(&1, 1), 0) == :error))
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(&Meilisearch.Index.delete(client, &1))
      |> Enum.map(&elem(&1, 1))

    :ok = wait_for_tasks(tasks)
  end

  @doc """
  Reset specifically the tests indexes
  """
  def reset_tests() do
    indexes =
      @indexes
      |> Enum.filter(&String.contains?(&1, "test"))

    drop_all(indexes)
  end

  defp create_search_result(result) when is_map(result) do
    %SearchResult{
      facets: %{},
      hits: result.hits
    }
  end

  defp index_name(index) do
    # This function is fondamental to make it work locally.
    # We check if we are running in test environement. This way, we index document
    # in the corresponding test index
    if is_env_test(), do: index <> "_test", else: index
  end

  defp is_env_test() do
    app = Application.get_application(__MODULE__)

    {:database, database} =
      Application.get_env(app, TeacherCoop.Repo) |> List.keyfind(:database, 0)

    String.contains?(database, "test")
  end

  defp create_indexes(indexes) do
    client = get_client()

    tasks =
      indexes
      |> Enum.map(&Meilisearch.Index.create(client, %{uid: &1, primaryKey: "id"}))
      |> Enum.map(&elem(&1, 1))

    result = wait_for_tasks(tasks)

    if result == :ok,
      do: IO.puts("All index created"),
      else: IO.puts("Error while creating indexes")
  end

  defp wait_for_tasks(tasks) when tasks == [] do
    :ok
  end

  defp wait_for_tasks(tasks) do
    result =
      tasks
      |> Enum.map(&wait_for_task(&1))
      |> Enum.all?(fn status -> status in [:succeeded] end)

    if result == true, do: :ok, else: :error
  end

  defp wait_for_task(task) do
    {:ok, task_details} = Meilisearch.Task.get(get_client(), task.taskUid)
    status = Map.get(task_details, :status)

    if status in [:enqueud, :processing] do
      Process.sleep(1000)
      wait_for_task(task)
    else
      status
    end
  end

  defp get_client() do
    # Convenient function that initialize finch client if necessary and returns
    # a Meilisearch client.
    init_finch()
    # Create a Meilisearch client whenever and wherever you need it.
    case Process.get(:meilisearch) do
      nil ->
        [endpoint: "http://127.0.0.1:7700", key: "masterkey", finch: :finch_meilisearch]
        |> Meilisearch.Client.new()

      _ ->
        Meilisearch.client(:meilisearch)
    end
  end

  defp init_finch() do
    if Process.get(:finch_meilisearch) == nil do
      Finch.start_link(name: :finch_meilisearch)
    end
  end
end

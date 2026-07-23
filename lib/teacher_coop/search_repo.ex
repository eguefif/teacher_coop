defmodule TeacherCoop.SearchRepo do
  @moduledoc """
  SearchRepo is a layer between the Search Engine and the application
  This module in particular is used to setup Meilisearch.
  """
  @indexes ["documents", "documents_test", "objectives", "objectives_test"]

  @doc """
   Convenient function that initialize finch client if necessary and returns
   a Meilisearch client.
  """
  def get_client() do
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

  @doc """
  Initliazes all the indexes after dropping them.
  """
  def init_indexes() do
    IO.puts("Starting meilisearch operations for reset")
    IO.puts(" 1. Dropped all index")
    drop_all(@indexes)
    IO.puts(" 2. Recreated index")
    create_indexes(@indexes)
    IO.puts(" 3. Define embedders")
    configure_embedder()
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
    create_indexes(indexes)
  end

  @doc """
  This function returns the correct index_name depending on the environment
  """
  def index_name(index) do
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

    update_index_settings()

    if result == :ok,
      do: IO.puts("All index created"),
      else: IO.puts("Error while creating indexes")
  end

  defp update_index_settings() do
    client = get_client()
    Meilisearch.Settings.FilterableAttributes.update(client, "documents_test", ["user_id"])
  end

  def wait_for_tasks(tasks) when tasks == [] do
    :ok
  end

  def wait_for_tasks(tasks) do
    result =
      tasks
      |> Enum.map(&wait_for_task(&1.taskUid))
      |> Enum.all?(fn status -> status in [:succeeded] end)

    if result == true, do: :ok, else: :error
  end

  defp wait_for_task(task_uid) do
    {:ok, task_details} = Meilisearch.Task.get(get_client(), task_uid)
    status = Map.get(task_details, :status)
    wait_time = if is_env_test(), do: 1, else: 250

    if status in [:enqueued, :processing] do
      Process.sleep(wait_time)
      wait_for_task(task_uid)
    else
      status
    end
  end

  defp init_finch() do
    if Process.get(:finch_meilisearch) == nil do
      Finch.start_link(name: :finch_meilisearch)
    end
  end

  defp configure_embedder() do
    embedder = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"

    embedder_config = %{
      "default" => %{
        "source" => "huggingFace",
        "model" => embedder,
        "documentTemplate" => get_template()
      }
    }

    {:ok, task} =
      get_client()
      |> Tesla.patch("/indexes/documents/settings/embedders", embedder_config)
      |> Meilisearch.Client.handle_response()

    :succeeded = wait_for_task(task["taskUid"])
  end

  defp get_template() do
    "Un document nommé {{doc.title}} avec pour description {{doc.description}} et dont les objectifs sont: {{doc.objectives}}."
  end
end

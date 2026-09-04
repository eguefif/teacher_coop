defmodule TeacherCoop.SearchRepo do
  @moduledoc """
  SearchRepo is a layer between the Search Engine and the application
  This module in particular is used to setup Meilisearch.
  """
  alias TeacherCoop.Discovery.Configuration.Index

  @doc """
  Function used for search test A/B. At the moments, it returns only one index.
  In the future, this function will returns either documents_a or documents_b.
  To make test A/B, we set up two index with different configuration.
  To not make a test, we copy the settings from a to b.
  """
  def get_document_index_test_a_b() do
    "documents"
  end

  @doc """
  Get all fields from an index: returns an array
  """
  def list_fields_for(indexname) do
    client = get_client()

    response =
      Tesla.post(client, "/indexes/#{indexname}/fields", "{\"offset\": 0, \"limit\": 50}")

    case Meilisearch.Client.handle_response(response) do
      {:ok, fields_map} ->
        Enum.map(fields_map["results"], & &1["name"])

      _ ->
        :error
    end
  end

  @doc """
  Get all indexes. This function will call Meilisearch directly.
  """
  def list_index_names() do
    {status, result} =
      get_client()
      |> Meilisearch.Index.list()

    case status do
      :ok -> result |> Map.get(:results) |> Enum.map(& &1.uid)
      :error -> :error
    end
  end

  @doc """
  Configure an index with the settings.
  Settings should be a map. The function will camelCase all the keys.
  """
  def set_index(index_name, %{} = settings) do
    settings =
      camelize_keys(settings)

    {result, task} =
      get_client()
      |> Meilisearch.Settings.update(index_name, settings)

    case result do
      :ok -> wait_for_task(task)
      :error -> :error
    end
  end

  @doc "Recursively convert map keys from snake_case to camelCase."
  def camelize_keys(map) when is_map(map) and not is_struct(map) do
    Map.new(map, fn {k, v} -> {camelize_key(k), camelize_keys(v)} end)
  end

  def camelize_keys(list) when is_list(list), do: Enum.map(list, &camelize_keys/1)
  def camelize_keys(value), do: value

  defp camelize_key(key) when is_atom(key), do: key |> Atom.to_string() |> camelize_key()

  defp camelize_key(key) when is_binary(key) do
    case String.split(key, "_", trim: true) do
      [] -> key
      [first | rest] -> first <> Enum.map_join(rest, "", &upcase_first/1)
    end
  end

  defp upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest
  defp upcase_first(""), do: ""

  @doc """
   Convenient function that initialize finch client if necessary and returns
   a Meilisearch client.
  """
  def get_client() do
    init_finch()
    meilisearch_config = Application.fetch_env!(:teacher_coop, TeacherCoop.SearchRepo)
    masterkey = meilisearch_config |> List.keyfind(:masterkey, 0) |> elem(1)
    host = meilisearch_config |> List.keyfind(:hostname, 0) |> elem(1)
    port = meilisearch_config |> List.keyfind(:port, 0) |> elem(1)
    hostname = "#{host}:#{port}"
    # Create a Meilisearch client whenever and wherever you need it.
    case Process.get(:meilisearch) do
      nil ->
        [endpoint: hostname, key: masterkey, finch: :finch_meilisearch]
        |> Meilisearch.Client.new()

      _ ->
        Meilisearch.client(:meilisearch)
    end
  end

  @doc """
  Initliazes all the indexes after dropping them.
  """
  def init_indexes() do
    definitions = Index.definitions()

    IO.puts("Starting meilisearch operations for reset")
    IO.puts(" 1. Dropped all index")
    drop_all(Enum.map(definitions, & &1.uid))
    IO.puts(" 2. Recreated index")
    create_indexes(definitions)
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
    definitions =
      Index.definitions()
      |> Enum.filter(&String.contains?(&1.uid, "test"))

    drop_all(Enum.map(definitions, & &1.uid))
    create_indexes(definitions)
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

  defp create_indexes(definitions) do
    client = get_client()

    tasks =
      definitions
      |> Enum.map(&Meilisearch.Index.create(client, %{uid: &1.uid, primaryKey: &1.primary_key}))
      |> Enum.map(&elem(&1, 1))

    result = wait_for_tasks(tasks)

    update_index_settings("documents")
    update_index_settings("documents_test")

    if result == :ok,
      do: IO.puts("All index created"),
      else: IO.puts("Error while creating indexes")
  end

  defp update_index_settings(index) do
    client = get_client()

    Meilisearch.Settings.FilterableAttributes.update(client, index, [
      "user_id",
      "institution_type",
      "grade"
    ])
  end

  @doc """
  Wait for Meilisearch set of Tasks to be done
  Takes an array of `%Task{}`.
  Returns `:ok` or `:error`.
  """
  def wait_for_tasks(tasks) when is_list(tasks) do
    result =
      tasks
      |> Enum.map(&wait_for_task_loop(&1.taskUid))
      |> Enum.all?(fn status -> status in [:ok] end)

    if result == true, do: :ok, else: :error
  end

  @doc """
  Wait for a Meilisearch Task to be done
  Takes a `%Task{}`
  Returns `:ok` or `:error`.
  """
  def wait_for_task(%{"taskUid" => uid} = _) do
    wait_for_task_loop(uid)
  end

  def wait_for_task(%{taskUid: uid} = _) do
    wait_for_task_loop(uid)
  end

  defp wait_for_task_loop(task_uid) do
    {:ok, task_details} = Meilisearch.Task.get(get_client(), task_uid)
    status = Map.get(task_details, :status)
    wait_time = if is_env_test(), do: 1, else: 500

    if status in [:enqueued, :processing] do
      Process.sleep(wait_time)
      wait_for_task_loop(task_uid)
    else
      status
    end

    case status do
      value when value in [:enqueued, :processing] ->
        Process.sleep(wait_time)
        wait_for_task_loop(task_uid)

      :succeeded ->
        :ok

      _ ->
        :error
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

    :ok = wait_for_task(task)
  end

  defp get_template() do
    "Un document nommé {{doc.title}} avec pour description {{doc.description}} et dont les objectifs sont: {{doc.objectives}}."
  end
end

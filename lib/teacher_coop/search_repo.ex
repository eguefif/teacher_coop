defmodule TeacherCoop.SearchRepo do
  @moduledoc """
  SearchRepo is a layer between the Search Engine and the application
  This module in particular is used to setup Meilisearch.
  """

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
  def list_fields_for(indexuid) do
    client = get_client()

    response =
      Tesla.post(client, "/indexes/#{indexuid}/fields", "{\"offset\": 0, \"limit\": 50}")

    case Meilisearch.Client.handle_response(response) do
      {:ok, fields_map} ->
        Enum.map(fields_map["results"], & &1["name"])

      _ ->
        :error
    end
  end

  @doc """
  Configure an index with the settings.
  Settings should be a map. The function will camelCase all the keys.
  """
  def update_index_settings(index_name, %{} = settings) do
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

  @doc """
  Convenient function to retrieve meilisearch client.
  This return the application based client in a prod/dev environnement.
  Returns a on the fly created client for test.
  """
  def get_client() do
    meilisearch_config = Application.fetch_env!(:teacher_coop, TeacherCoop.SearchRepo)
    masterkey = meilisearch_config |> List.keyfind(:masterkey, 0) |> elem(1)
    host = meilisearch_config |> List.keyfind(:hostname, 0) |> elem(1)
    port = meilisearch_config |> List.keyfind(:port, 0) |> elem(1)
    hostname = "#{host}:#{port}"
    # Create a Meilisearch client whenever and wherever you need it.
    case Process.get(:meilisearch) do
      nil ->
        init_finch()

        [endpoint: hostname, key: masterkey, finch: :finch_meilisearch]
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

defmodule TeacherCoop.SearchRepo.Init do
  import TeacherCoop.SearchRepo
  alias TeacherCoop.Discovery.Configuration.Index

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

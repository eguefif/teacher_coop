defmodule Meilisearch.TeacherCoopDocuments do
  def populate() do
    meili_master_key = Dotenv.get("MEILI_MASTER_KEY")
    meili_host = Dotenv.get("MEILISEARCH_HOST")
    Finch.start_link(name: :meili_finch)

    client =
      [endpoint: meili_host, key: meili_master_key, finch: :meili_finch]
      |> Meilisearch.Client.new()

    case Meilisearch.Index.get(client, "documents") do
      {:ok, _} ->
        {:ok, task} = Meilisearch.Index.delete(client, "documents")
        wait_for_task(client, task, "Delete index documents")

      {:error,
       %Meilisearch.Error{
         message: "Index `documents` not found.",
         link: "https://docs.meilisearch.com/errors#index_not_found",
         type: :invalid_request,
         code: :index_not_found
       }, 404} ->
        IO.puts("Index Documents not found")

      _ ->
        IO.puts("Error checking if index documents exists")
    end

    {:ok, task} = Meilisearch.Index.create(client, %{uid: "documents", primaryKey: "id"})
    wait_for_task(client, task, "Create index documents")
  end

  defp wait_for_task(client, task, task_type) do
    {:ok, response} =
      Meilisearch.Task.get(client, task.taskUid)

    case Map.get(response, "status") do
      "enqueued" ->
        Process.sleep(500)
        wait_for_task(client, task, task_type)

      "processing" ->
        Process.sleep(500)
        wait_for_task(client, task, task_type)

      status ->
        IO.puts("Task " <> task_type <> " done with status #{status}")
    end
  end
end

IO.puts("\n************** Indexing Documents *********************\n")
Meilisearch.TeacherCoopDocuments.populate()

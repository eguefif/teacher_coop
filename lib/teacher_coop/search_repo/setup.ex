defmodule TeacherCoop.SearchRepo.Setup do
  import TeacherCoop.SearchRepo

  def update_config(indexname, config) do
    client = get_client()

    case Meilisearch.Settings.update(client, indexname, config) do
      {:ok, %Meilisearch.SummarizedTask{} = task} ->
        wait_for_tasks([task])
        :ok

      {:error, _} ->
        :error
    end
  end
end

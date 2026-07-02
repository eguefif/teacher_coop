defmodule TeacherCoop.SearchRepo.SearchObjectives do
  import TeacherCoop.SearchRepo

  def index_objective(attrs, wait_task \\ false) do
    case Meilisearch.Document.create_or_replace(get_client(), "objectives", attrs) do
      {:ok, %Meilisearch.SummarizedTask{} = task} when wait_task == true ->
        wait_for_tasks([task])
        :ok

      {:ok, _} ->
        :ok

      {:error, _} ->
        :error
    end
  end

  def populate_objectives_index(attrs \\ []) when is_list(attrs) do
    case Meilisearch.Document.create_or_replace(get_client(), "objectives", attrs) do
      {:ok, %Meilisearch.SummarizedTask{} = task} ->
        wait_for_tasks([task])
        :ok

      {:error, _} ->
        :error
    end
  end

  def reset_objectives_index() do
    case Meilisearch.Index.delete(get_client(), "objectives") do
      {:ok, %Meilisearch.SummarizedTask{} = task} ->
        wait_for_tasks([task])
        :ok

      {:error, _} ->
        :error
    end
  end
end

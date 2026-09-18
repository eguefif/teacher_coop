defmodule TeacherCoop.SearchRepo.SearchObjectives do
  import TeacherCoop.SearchRepo

  def search(input) do
    case Meilisearch.Search.search(get_client(), index_name("objectives"), q: input) do
      {:ok, results} ->
        results.hits

      {:error, error} ->
        {:error, error}
    end
  end

  def index_objective(attrs, wait_task \\ false) do
    case Meilisearch.Document.create_or_replace(get_client(), index_name("objectives"), attrs) do
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
    case Meilisearch.Document.create_or_replace(get_client(), index_name("objectives"), attrs) do
      {:ok, %Meilisearch.SummarizedTask{} = task} ->
        wait_for_tasks([task])
        :ok

      {:error, _} ->
        :error
    end
  end

  def reset_objectives_index() do
    case Meilisearch.Index.delete(get_client(), index_name("objectives")) do
      {:ok, %Meilisearch.SummarizedTask{} = task} ->
        wait_for_tasks([task])
        :ok

      {:error, _} ->
        :error
    end
  end
end

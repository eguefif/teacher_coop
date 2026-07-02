defmodule TeacherCoop.SearchRepo.SearchObjectives do
  import TeacherCoop.SearchRepo
  alias TeacherCoop.Curriculum.Objective

  def index_objective(%Objective{} = objective, wait_task \\ false) do
    attrs =
      Map.from_struct(objective)
      |> Map.delete(:__meta__)

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

  def populate_objectives_index(entries \\ []) when is_list(entries) do
    [:ok] =
      entries
      |> Enum.map(&index_objective/1)
      |> Enum.uniq()
  end
end

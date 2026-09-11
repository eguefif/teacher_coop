defmodule TeacherCoopWeb.CurriculumJSON do
  alias TeacherCoop.Curriculum.Objective

  @doc """
  Renders a list of urls.
  """
  def index(%{curriculum: curriculum}) do
    %{data: for(entry <- curriculum, do: data(entry))}
  end

  defp data(%Objective{} = objective) do
    %{
      year: objective.year,
      subject: objective.subject,
      grade: objective.grade,
      strand: objective.strand,
      goal: objective.goal
    }
  end
end

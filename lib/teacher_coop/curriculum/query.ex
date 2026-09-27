defmodule TeacherCoop.Curriculum.Query do
  import Ecto.Query

  alias TeacherCoop.Curriculum.Objective

  @spec base() :: Ecto.Query.t()
  def base(), do: from(c in Objective)

  @spec where_year(Ecto.Query.t(), integer()) :: Ecto.Query.t()
  def where_year(query, year) do
    query
    |> where([c], c.year == ^year)
  end

  @spec group_by_grade_and_subject(Ecto.Query.t()) :: Ecto.Query.t()
  def group_by_grade_and_subject(query) do
    query
    |> select([c], %{grade: c.grade, subject: c.subject, count: count(c.id)})
    |> group_by([c], [c.grade, c.subject])
  end
end

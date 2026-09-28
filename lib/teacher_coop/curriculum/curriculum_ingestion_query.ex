defmodule TeacherCoop.Curriculum.CurriculumIngestionQuery do
  import Ecto.Query
  alias TeacherCoop.Curriculum.CurriculumIngestion

  def base(), do: from(c in CurriculumIngestion)

  @doc """
  Returns a query modifier that order by inserted_at desc
  and take the first n entries.
  """
  @spec last_n_entries(Ecto.Query.t(), integer()) :: Ecto.Query.t()
  def last_n_entries(query, n) do
    query
    |> order_by(desc: :inserted_at)
    |> limit(^n)
  end
end

defmodule TeacherCoop.CurriculumFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Curriculum` context.
  """

  @doc """
  Generate a objective.
  """
  def objective_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        goal: "some goal",
        grade: "some grade",
        subject: "some subject",
        year: 42
      })

    {:ok, objective} = TeacherCoop.Curriculum.create_objective(attrs)
    objective
  end
end

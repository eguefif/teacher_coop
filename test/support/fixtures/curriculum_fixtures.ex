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
        goal: "Compter plein de nombres",
        grade: "cm2",
        strand: "compter",
        subject: "mathématiques",
        year: 42
      })

    {:ok, objective} = TeacherCoop.Curriculum.create_objective(attrs)
    objective
  end

  @doc """
  Generate a curriculum_ingestion.
  """
  def curriculum_ingestion_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        year: 2020,
        subject: "français",
        state: "created"
      })

    {:ok, curriculum_ingestion} = TeacherCoop.Curriculum.create_curriculum_ingestion(attrs)
    curriculum_ingestion
  end
end

defmodule TeacherCoop.CurriculumFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Curriculum` context.
  """
  alias TeacherCoop.AccountsFixtures

  @doc """
  Generate a objective.
  """
  def objective_fixture(attrs \\ %{}) do
    scope = AccountsFixtures.admin_scope_fixture()

    attrs =
      Enum.into(attrs, %{
        goal: "Compter plein de nombres",
        grade: "cm2",
        strand: "compter",
        subject: "mathématiques",
        year: 42
      })

    {:ok, objective} = TeacherCoop.Curriculum.create_objective(scope, attrs)
    objective
  end

  @doc """
  Generate a curriculum_ingestion.
  """
  def curriculum_ingestion_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        year: 2020,
        subject: "français",
        state: "created"
      })

    {:ok, curriculum_ingestion} = TeacherCoop.Curriculum.create_curriculum_ingestion(scope, attrs)
    curriculum_ingestion
  end
end

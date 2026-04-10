defmodule TeacherCoop.CurriculumFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Curriculum` context.
  """

  @doc """
  Generate a curriculum_item.
  """
  def curriculum_item_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{

      })

    {:ok, curriculum_item} = TeacherCoop.Curriculum.create_curriculum_item(scope, attrs)
    curriculum_item
  end
end

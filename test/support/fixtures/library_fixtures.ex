defmodule TeacherCoop.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Library` context.
  """

  alias TeacherCoop.CurriculumFixtures

  @doc """
  Generate a document.
  """
  def document_fixture(scope, attrs \\ %{}) do
    objective = CurriculumFixtures.objective_fixture()

    attrs =
      Enum.into(attrs, %{
        description: "some description",
        title: "some title",
        institution_type: "Tout le monde",
        grade: "CM2",
        files: [%{filename: "lesson.pdf", filepath: "uploads/lesson.pdf", format: "pdf"}]
      })

    {:ok, document} =
      TeacherCoop.Library.create_document(scope, attrs, [objective.id])

    document |> TeacherCoop.Repo.preload(:user) |> TeacherCoop.Repo.preload(:objectives)
  end

  @doc """
  Generate a persisted file.
  """
  def file_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        filename: "lesson.pdf",
        filepath: "uploads/lesson.pdf",
        format: "pdf"
      })

    {:ok, file} =
      %TeacherCoop.Library.File{}
      |> TeacherCoop.Library.File.changeset(attrs)
      |> TeacherCoop.Repo.insert()

    file
  end
end

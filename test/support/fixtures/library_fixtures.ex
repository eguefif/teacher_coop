defmodule TeacherCoop.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Library` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(scope, attrs \\ %{}) do
    objective_fixture = %{
      goal: "some goal",
      grade: "some grade",
      subject: "some subject",
      year: 42
    }

    attrs =
      Enum.into(attrs, %{
        description: "some description",
        title: "some title",
        institution_type: "Tout le monde",
        grade: "CM2",
        objectives: [objective_fixture]
      })

    {:ok, document} = TeacherCoop.Library.create_document(scope, attrs)
    document
  end
end

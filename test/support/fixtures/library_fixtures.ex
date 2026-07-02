defmodule TeacherCoop.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Library` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        title: "some title",
        institution_type: "Tout le monde",
        grade: "CM2"
      })

    {:ok, document} = TeacherCoop.Library.create_document(scope, attrs)
    document
  end
end

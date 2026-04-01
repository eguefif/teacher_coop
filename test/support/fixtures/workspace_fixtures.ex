defmodule TeacherCoop.WorkspaceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Workspace` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "some title"
      })

    {:ok, document} = TeacherCoop.Workspace.create_document(scope, attrs)
    document
  end
end

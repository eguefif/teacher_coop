defmodule TeacherCoop.ConfigurationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Configuration` context.
  """

  @doc """
  Generate a document.
  """
  def index_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some description",
        type: "original",
        state: "indexed"
      })

    {:ok, document} = TeacherCoop.Discovery.Configuration.create_index(attrs, scope)
    document
  end
end

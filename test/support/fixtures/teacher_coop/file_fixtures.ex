defmodule TeacherCoop.TeacherCoop.FileFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.TeacherCoop.File` context.
  """

  @doc """
  Generate a file.
  """
  def file_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        filename: "some filename",
        path: "some path"
      })

    {:ok, file} = TeacherCoop.TeacherCoop.File.create_file(scope, attrs)
    file
  end
end

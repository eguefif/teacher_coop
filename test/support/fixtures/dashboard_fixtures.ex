defmodule TeacherCoop.DashboardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Dashboard` context.
  """

  alias TeacherCoop.Dashboard.WordCount
  alias TeacherCoop.Repo

  @doc """
  Generate a persisted `WordCount` entry.
  """
  @spec word_count_fixture(map()) :: WordCount.t() | nil
  def word_count_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        word: "geometri",
        frequency: 5,
        zero_result_count: 0,
        date: Date.utc_today()
      })

    {:ok, search} =
      %WordCount{}
      |> WordCount.changeset(attrs)
      |> Repo.insert()

    search
  end
end

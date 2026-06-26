defmodule TeacherCoop.DiscoveryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Discovery` context.
  """

  @doc """
  Generate a search.
  """
  def search_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        search_terms: "some search_terms"
      })

    {:ok, search} = TeacherCoop.Discovery.create_search(scope, attrs)
    search
  end
end

defmodule TeacherCoop.DiscoveryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Discovery` context.
  """

  @doc """
  Generate a search.
  """
  def search_fixture(scope, search_terms \\ "some serach_terms") do
    search_session = TeacherCoop.create_search_session(scope)

    {:ok, search} = TeacherCoop.Discovery.handle_search(search_session, search_terms)
    search
  end
end

defmodule TeacherCoop.DiscoveryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Discovery` context.
  """

  alias TeacherCoop.Discovery
  alias TeacherCoop.Discovery.Search
  alias TeacherCoop.Repo

  @doc """
  Generate a persisted search record owned by the given scope's user.
  """
  def search_fixture(scope, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{search_terms: "some search terms"})

    {:ok, search} =
      %Search{}
      |> Search.changeset(attrs, scope)
      |> Repo.insert()

    search
  end

  @doc """
  Generate a search session for the given scope.
  Pass `attrs` (a map or keyword list) to override struct fields,
  e.g. `search_session_fixture(scope, search_record: search_fixture(scope))`.
  """
  def search_session_fixture(scope, attrs \\ %{}) do
    scope
    |> Discovery.create_search_session()
    |> struct(attrs)
  end
end

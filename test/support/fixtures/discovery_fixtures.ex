defmodule TeacherCoop.DiscoveryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Discovery` context.
  """

  alias TeacherCoop.Discovery.Search
  alias TeacherCoop.Repo

  @doc """
  Generate a persisted search record owned by the given scope's user.
  """
  def search_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        search_terms: "some search terms",
        search_session: Ecto.UUID.generate(version: 7)
      })

    {:ok, search} =
      %Search{}
      |> Search.changeset(attrs, scope)
      |> Repo.insert()

    search
  end
end

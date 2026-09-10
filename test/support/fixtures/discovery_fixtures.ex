defmodule TeacherCoop.DiscoveryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Discovery` context.
  """

  alias TeacherCoop.Discovery.Search
  alias TeacherCoop.Repo

  @doc """
  Generate a persisted search record owned by the given scope's user.

  Pass `:inserted_at` (a `DateTime`) in `attrs` to backdate the record; the
  auto-managed timestamps would otherwise force it to `now`. This is handy for
  building a history of searches spread over several days.
  """
  def search_fixture(scope, attrs \\ %{}) do
    {inserted_at, attrs} =
      attrs
      |> Map.new()
      |> Map.pop(:inserted_at)

    attrs =
      Enum.into(attrs, %{
        search_terms: "some search terms",
        search_session: Ecto.UUID.generate(version: 7)
      })

    {:ok, search} =
      %Search{}
      |> Search.changeset(attrs, scope)
      |> Repo.insert()

    case inserted_at do
      nil ->
        search

      %DateTime{} = inserted_at ->
        search
        |> Ecto.Changeset.change(inserted_at: DateTime.truncate(inserted_at, :second))
        |> Repo.update!()
    end
  end
end

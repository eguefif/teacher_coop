defmodule TeacherCoop.Repo.Seeds.IndexSeed do
  @moduledoc """
  Seeds the `indexes` table so it mirrors the indexes that exist in Meilisearch.

  The `uid` of each Meilisearch index is used as the index `name`.
  """

  alias TeacherCoop.Repo
  alias TeacherCoop.Discovery.Configuration.Index

  def seed do
    Enum.map(Index.definitions(), &upsert_index/1)
  end

  defp upsert_index(%{uid: uid} = attrs) do
    case Repo.get_by(Index, name: uid) do
      nil ->
        Repo.insert!(%Index{name: uid, primary_key: attrs.primary_key, type: attrs.type})

      %Index{} = index ->
        index
    end
  end
end

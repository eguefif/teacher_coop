defmodule TeacherCoop.Workspace do
  @moduledoc """
  The Workspace context.
  """

  import Ecto.Query, warn: false
  alias TeacherCoop.Repo

  alias TeacherCoop.Workspace.Document
  alias TeacherCoop.Workspace.Tags
  alias TeacherCoop.Workspace.File
  alias TeacherCoop.Accounts.Scope

  def list_documents(%Scope{} = scope) do
    Repo.all_by(Document, user_id: scope.user.id)
  end

  def get_document!(%Scope{} = scope, id) do
    Repo.get_by!(Document, id: id, user_id: scope.user.id)
  end

  def get_file!(%Scope{} = scope, id) do
    query =
      from file in File,
        join: document in Document,
        on: document.id == file.document_id,
        where: file.id == ^id and document.user_id == ^scope.user.id

    Repo.one!(query)
  end

  def create_document(%Scope{} = scope, files, attrs) do
    Repo.transaction(fn ->
      document =
        %Document{}
        |> Document.changeset(attrs, scope)
        |> Repo.insert!()

      Enum.each(files, fn file ->
        %File{}
        |> File.changeset(file, scope)
        |> Ecto.Changeset.put_change(:document_id, document.id)
        |> Repo.insert!()
      end)

      document
    end)
  end

  def update_document(%Scope{} = scope, %Document{} = document, files, attrs) do
    true = document.user_id == scope.user.id

    Repo.transaction(fn ->
      document =
        document
        |> Document.changeset(attrs, scope)
        |> Repo.update!()

      Enum.each(files, fn file ->
        %File{}
        |> File.changeset(file, scope)
        |> Ecto.Changeset.put_change(:document_id, document.id)
        |> Repo.insert!()
      end)

      document
    end)
  end

  def delete_document(%Scope{} = scope, %Document{} = document) do
    true = document.user_id == scope.user.id

    Repo.delete(document)
  end

  def change_document(%Scope{} = scope, %Document{} = document, attrs \\ %{}) do
    true = document.user_id == scope.user.id

    Document.changeset(document, attrs, scope)
  end

  def validate_change(%Scope{} = scope, %Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs, scope)
  end

  def get_files(id) do
    query =
      Ecto.Query.from(files in File,
        where: files.document_id == ^id,
        select: files
      )

    Repo.all(query)
  end

  def delete_file!(id) do
    file = Repo.get!(File, id)
    Repo.delete!(file)
  end

  def autocomplete_tags(tag) do
    Tags.get_all_tags()
    |> Enum.map(fn entry -> {entry, String.jaro_distance(entry, tag)} end)
    |> Enum.filter(fn {_, jaro} -> jaro > 0.5 end)
    |> Enum.sort(fn {_, jaro1}, {_, jaro2} -> jaro1 > jaro2 end)
    |> Enum.map(fn {entry, _} -> entry end)
  end

  def autocomplete_curriculum(curriculum) do
    {:ok, results} = Meilisearch.Search.search("curriculum", curriculum, limit: 15)

    case Map.get(results, "hits") do
      nil -> []
      hits -> Enum.map(hits, fn hit -> %{id: Map.get(hit, "id"), value: Map.get(hit, "item")} end)
    end
  end

  def update_public(%Scope{} = scope, id, value) do
    # TODO: update Meilisearch
    document = Repo.get!(Document, id)

    true =
      document.user_id ==
        scope.user.id

    document
    |> Document.changeset(%{public: value}, scope)
    |> Repo.update!()
  end
end

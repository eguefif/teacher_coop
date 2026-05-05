defmodule TeacherCoop.Workspace do
  @moduledoc """
  The Workspace context.
  """

  import Ecto.Query, warn: false

  alias TeacherCoop.Repo
  alias Ecto.Multi
  alias TeacherCoop.Workspace.Document
  alias TeacherCoop.Workspace.Tags
  alias TeacherCoop.Workspace.File
  alias TeacherCoop.Workspace.Groups.Membership
  alias TeacherCoop.Workspace.Groups.DocumentWorkingGroup
  alias TeacherCoop.Accounts.Scope

  def list_documents(%Scope{} = scope) do
    Repo.all_by(Document, user_id: scope.user.id)
  end

  def get_document!(%Scope{} = scope, id) do
    accessible_document(scope)
    |> Repo.get_by!(id: id)
  end

  defp accessible_document(%Scope{} = scope) do
    # TODO: Test this function:
    # 1. if the user is the owner
    # 2. If the document is public
    # 3. If the user is in a group that has the document
    from d in Document,
      join: m in Membership,
      on: m.user_id == ^scope.user.id,
      left_join: dg in DocumentWorkingGroup,
      on: dg.working_group_id == m.working_group_id,
      where: d.user_id == ^scope.user.id or d.public == true or not is_nil(dg.id)
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
    result =
      Repo.transaction(fn ->
        document =
          %Document{}
          |> Document.changeset(attrs, scope)
          |> Repo.insert()

        Enum.each(files, fn file ->
          %File{}
          |> File.changeset(file, scope)
          |> Ecto.Changeset.put_change(:document_id, document.id)
          |> Repo.insert!()
        end)

        document
      end)

    document = elem(result, 1)

    meili_doc = %{
      id: document.id,
      public: document.public,
      tags: document.tags,
      goals: document.goals,
      author: document.user_id
    }

    :meili_teachercoop
    |> Meilisearch.client()
    |> Meilisearch.Document.create_or_update("documents", meili_doc)

    result
  end

  def update_document(%Scope{} = scope, %Document{} = document, files, attrs) do
    document = Repo.get!(Document, document.id)
    true = document.user_id == scope.user.id

    document_changeset = Document.changeset(document, attrs, scope)

    result =
      Multi.new()
      |> Multi.update(:update_document, document_changeset)
      |> Multi.insert_all(:insert_files, File, files)
      |> Repo.transact()

    case result do
      {:ok, update_document: document, insert_files: _files} ->
        update_meilisearch_document(document)

      {:error, :update_document, failed_value, _changes_so_far} ->
        {:error_document, failed_value}

      {:error, :insert_files, failed_value, _changes_so_far} ->
        {:error_files, failed_value}
    end
  end

  defp update_meilisearch_document(document) do
    meili_doc = %{
      id: document.id,
      public: document.public,
      tags: document.tags,
      goals: document.goals,
      author: document.user_id
    }

    :meili_teachercoop
    |> Meilisearch.client()
    |> Meilisearch.Document.create_or_update("documents", meili_doc)
  end

  def delete_document(%Scope{} = scope, %Document{} = document) do
    # TODO: Check authorization
    document = Repo.get(Document, document.id)
    true = document.user_id == scope.user.id

    files_query = from file in File, where: file.document_id == ^document.id, select: file.id

    # TODO: Refactor meilisearch in background job to handle retry and make
    # sure updates are eventually done.
    :meili_teachercoop
    |> Meilisearch.client()
    |> Meilisearch.Document.delete_one("documents", document.id)

    Repo.transaction(fn ->
      Repo.delete_all(files_query)
      Repo.delete(document)
    end)
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
    {:ok, results} =
      :meili_teachercoop
      |> Meilisearch.client()
      |> Meilisearch.Search.search("curriculum", q: curriculum, limit: 15)

    Enum.map(results.hits, fn hit -> %{id: Map.get(hit, "id"), value: Map.get(hit, "item")} end)
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

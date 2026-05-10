defmodule TeacherCoop.Workspace do
  @moduledoc """
  The Workspace context.
  """

  import Ecto.Query, warn: false

  alias TeacherCoop.Repo
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
    # A document has many files
    # Document is user input
    # File is user input
    # Use cast_assoc
    attrs = Map.put(attrs, "files", files)

    result =
      %Document{}
      |> Document.changeset(attrs, scope)
      |> Repo.insert()

    case result do
      {:ok, record} ->
        IO.inspect(record)

        document =
          record
          |> Repo.preload(:user)
          |> Repo.preload(:document_working_groups)
          |> Document.to_map()

        IO.inspect(document)

        task =
          :meili_teachercoop
          |> Meilisearch.client()
          |> Meilisearch.Document.create_or_update("documents", document)

        IO.inspect(task)

        result

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_document(%Scope{} = scope, %Document{} = document, files, attrs) do
    document =
      Repo.get!(Document, document.id)
      |> Repo.preload(:files)

    true = document.user_id == scope.user.id

    attrs = Map.put(attrs, "files", files)

    result =
      document
      |> Document.changeset_update(attrs)
      |> Repo.insert_or_update()

    case result do
      {:ok, record} ->
        document =
          record
          |> Map.from_struct()
          |> Map.drop([:files, :__meta__])

        update_meilisearch_document(document)
        {:ok, document}

      {:error, changeset} ->
        {:error_document, changeset}
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

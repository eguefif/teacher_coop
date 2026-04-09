defmodule TeacherCoop.Workspace do
  @moduledoc """
  The Workspace context.
  """

  import Ecto.Query, warn: false
  alias TeacherCoop.Repo

  alias TeacherCoop.Workspace.Document
  alias TeacherCoop.Workspace.File
  alias TeacherCoop.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any document changes.

  The broadcasted messages match the pattern:

    * {:created, %Document{}}
    * {:updated, %Document{}}
    * {:deleted, %Document{}}

  """
  def subscribe_documents(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(TeacherCoop.PubSub, "user:#{key}:documents")
  end

  defp broadcast_document(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(TeacherCoop.PubSub, "user:#{key}:documents", message)
  end

  @doc """
  Returns the list of documents.

  ## Examples

      iex> list_documents(scope)
      [%Document{}, ...]

  """
  def list_documents(%Scope{} = scope) do
    Repo.all_by(Document, user_id: scope.user.id)
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(scope, 123)
      %Document{}

      iex> get_document!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(%Scope{} = scope, id) do
    Repo.get_by!(Document, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a document.

  ## Examples

      iex> create_document(scope, %{field: value})
      {:ok, %Document{}}

      iex> create_document(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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
    |> case do
      {:ok, document} ->
        broadcast_document(scope, {:created, document})
        {:ok, document}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(scope, document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(scope, document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Scope{} = scope, %Document{} = document, files, attrs) do
    true = document.user_id == scope.user.id

    result =
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

    case result do
      {:ok, document} ->
        broadcast_document(scope, {:updated, document})
        {:ok, document}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a document.

  ## Examples

      iex> delete_document(scope, document)
      {:ok, %Document{}}

      iex> delete_document(scope, document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Scope{} = scope, %Document{} = document) do
    true = document.user_id == scope.user.id

    with {:ok, document = %Document{}} <-
           Repo.delete(document) do
      broadcast_document(scope, {:deleted, document})
      {:ok, document}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(scope, document)
      %Ecto.Changeset{data: %Document{}}

  """
  def change_document(%Scope{} = scope, %Document{} = document, attrs \\ %{}) do
    true = document.user_id == scope.user.id

    Document.changeset(document, attrs, scope)
  end

  def get_file!(scope, id) do
    Repo.get_by!(File, id: id, user_id: scope.user.id)
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

  def get_tags_from_indexes(indexes) do
    indexes = String.split(indexes)

    case indexes do
      [] ->
        []

      _ ->
        TeacherCoop.Tags
        |> Map.filter(fn {index, _} -> Enum.any?(indexes, fn idx -> idx == index end) end)
        |> Map.values()
    end
  end

  def autocomplete_tags(tag) do
    TeacherCoop.Tags.get_all_tags()
    |> Enum.map(fn entry -> {entry, String.jaro_distance(entry, tag)} end)
    |> Enum.filter(fn {_, jaro} -> jaro > 0.5 end)
    |> Enum.sort(fn {_, jaro1}, {_, jaro2} -> jaro1 > jaro2 end)
    |> Enum.map(fn {entry, _} -> entry end)
  end
end

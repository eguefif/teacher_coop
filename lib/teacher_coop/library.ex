defmodule TeacherCoop.Library do
  import Ecto.Query, warn: false
  alias TeacherCoop.Repo

  alias TeacherCoop.Library.{Document, Workers}
  alias TeacherCoop.Curriculum
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
    Repo.all_by(Document, user_id: scope.user.id) |> Repo.preload(:objectives)
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id) do
    Repo.get_by!(Document, id: id)
    |> Repo.preload(:files)
    |> Repo.preload(:objectives)
  end

  @doc """
  Creates a document.
  ## Examples

      iex> create_document(scope, %{field: value})
      {:ok, %Document{}}

      iex> create_document(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(%Scope{} = scope, attrs, objective_ids \\ []) do
    objectives = Repo.all(from c in Curriculum.Objective, where: c.id in ^objective_ids)

    with {:ok, document = %Document{}} <-
           %Document{}
           |> Document.changeset(attrs, scope, objectives)
           |> Repo.insert() do
      schedule_indexing_document_job(scope, document)
      broadcast_document(scope, {:created, document})
      {:ok, document}
    end
  end

  defp schedule_indexing_document_job(%Scope{} = scope, %Document{} = document) do
    attrs =
      TeacherCoop.SearchRepo.SearchDocuments.create_attributes_from_document(scope, document)

    %{attrs: attrs}
    |> Workers.IndexDocument.new()
    |> Oban.insert()
  end

  defp schedule_delete_document_from_index_job(document_id) do
    %{document_id: document_id}
    |> Workers.DeleteDocument.new()
    |> Oban.insert()
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(scope, document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(scope, document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Scope{} = scope, %Document{} = document, attrs, objective_ids \\ []) do
    true = document.user_id == scope.user.id
    objectives = Repo.all(from c in Curriculum.Objective, where: c.id in ^objective_ids)

    with {:ok, document = %Document{}} <-
           document
           |> Document.changeset(attrs, scope, objectives)
           |> Repo.insert_or_update() do
      schedule_indexing_document_job(scope, document)
      broadcast_document(scope, {:updated, document})
      {:ok, document}
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
    files = Enum.map(document.files, fn file -> file.filepath end)

    with {:ok, document = %Document{}} <-
           Repo.delete(document) do
      # TODO: add delete all files in a job
      schedule_files_deleting(files)
      schedule_delete_document_from_index_job(document.id)
      broadcast_document(scope, {:deleted, document})
      {:ok, document}
    end
  end

  defp schedule_files_deleting(files) do
    %{files: files}
    |> Workers.DeleteFiles.new()
    |> Oban.insert()
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

  @doc """
  Delete a `%File{}` by id
  """
  def delete_file_by_id(id) do
    file = Repo.get(File, id)
    Repo.delete(file)
    schedule_delete_document_from_index_job(id)
  end
end

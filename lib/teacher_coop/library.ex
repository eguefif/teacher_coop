defmodule TeacherCoop.Library do
  @moduledoc """
  The Library context handles operations on documents. It has three schemas:
  * document
  * file
  * document_objective which is a many-to-many join table

  A document is composed of metadata (title, description, objectives) and files.

  Any time a user is creating/updating/deleting a document, we do three things:
  * Update the database with metadata and file's informations
  * Index/Reindex in SearchRepo
  * Add or delete a files on the disc

  Some operations trigger background jobs. Delete a document trigger two background jobs:
  * `Workers.DeleteDocument` will remove indexing from SearchRepo
  * `Workers.DeleteFile` will delete files

  Creating/Updating will trigger `Workers.IndexDocument` to index a document in SearchRepo.
  """
  import Ecto.Query, warn: false
  alias TeacherCoop.Repo

  alias TeacherCoop.Library.{Document, Workers, File}
  alias TeacherCoop.Curriculum
  alias TeacherCoop.Accounts.Scope

  # Document ************************************************************************

  @doc """
  Subscribes to scoped notifications about any document changes.

  The broadcasted messages match the pattern:

    * {:created, %Document{}}
    * {:updated, %Document{}}
    * {:deleted, %Document{}}

  """
  @spec subscribe_documents(Scope.t()) :: :ok | {:error, term()}
  def subscribe_documents(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(TeacherCoop.PubSub, "user:#{key}:documents")
  end

  @spec broadcast_document(Scope.t(), term()) :: :ok | {:error, term()}
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
  @spec list_documents(Scope.t()) :: [Document.t()]
  def list_documents(%Scope{} = scope) do
    Repo.all_by(Document, user_id: scope.user.id)
    |> Repo.preload(:objectives)
    |> Repo.preload(:files)
    |> Repo.preload(:user)
  end

  @doc """
  Returns the list of documents by ids.
  """
  @spec list_documents_by_ids([integer()]) :: [Document.t()]
  def list_documents_by_ids(ids) when ids != [] do
    Document.Query.base()
    |> Document.Query.by_ids(ids)
    |> Document.Query.with_files()
    |> Document.Query.with_objectives()
    |> Repo.all()
  end

  @spec list_documents_by_ids([]) :: []
  def list_documents_by_ids(ids) when ids == [] do
    ids
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
  @spec get_document!(integer()) :: Document.t()
  def get_document!(id) do
    Repo.get_by!(Document, id: id)
    |> Repo.preload(:user)
    |> Repo.preload(:files)
    |> Repo.preload(:objectives)
  end

  @doc """
  Creates a document in database, index to SearchRepo and save files on disc.
  ## Examples

      iex> create_document(scope, %{field: value})
      {:ok, %Document{}}

      iex> create_document(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_document(Scope.t(), map(), [integer()] | nil) ::
          {:ok, Document.t()} | {:error, Ecto.Changeset.t() | Oban.Job.changeset()}
  @dialyzer {:no_opaque, create_document: 3}
  def create_document(%Scope{} = scope, attrs, objective_ids \\ []) do
    objectives = Repo.all(from c in Curriculum.Objective, where: c.id in ^objective_ids)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:create, Document.changeset(%Document{}, attrs, scope, objectives))
      |> Oban.insert(:job, fn %{create: document} ->
        document = document |> Repo.preload(:files)
        create_indexing_document_job(scope, document)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{create: document, job: _job}} ->
        broadcast_document(scope, {:created, document})
        {:ok, document}

      {:error, :create, changeset, _} ->
        {:error, changeset}

      {:error, :job, job, _} ->
        {:error, job}
    end
  end

  defp create_indexing_document_job(%Scope{} = scope, %Document{} = document) do
    attrs =
      TeacherCoop.SearchRepo.SearchDocuments.create_attributes_from_document(scope, document)

    %{attrs: attrs}
    |> Workers.IndexDocument.new()
  end

  @doc """
  Updates a document in database, index to SearchRepo and save files on disc.

  ## Examples

      iex> update_document(scope, document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(scope, document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_document(Scope.t(), Document.t(), map()) ::
          {:ok, Document.t()} | {:error, Ecto.Changeset.t() | Oban.Job.changeset()}
  @dialyzer {:no_opaque, update_document: 4}
  def update_document(%Scope{} = scope, %Document{} = document, attrs, objective_ids \\ []) do
    true = document.user_id == scope.user.id
    objectives = Repo.all(from c in Curriculum.Objective, where: c.id in ^objective_ids)
    IO.puts("HEYYYYYYYYYYYYYYYYYYYYYYYYYYY")
    IO.inspect(objective_ids)
    IO.puts("HEYYYYYYYYYYYYYYYYYYYYYYYYYYY")

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:update, Document.changeset(document, attrs, scope, objectives))
      |> Oban.insert(:job, fn %{update: document} ->
        document = document |> Repo.preload(:files) |> Repo.preload(:objectives)
        create_indexing_document_job(scope, document)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{update: document, job: _}} ->
        broadcast_document(scope, {:updated, document})
        {:ok, document}

      {:error, :update, changeset, _} ->
        {:error, changeset}

      {:error, :job, job, _} ->
        {:error, job}
    end
  end

  @doc """
  Deletes a document from database, removes from SearchRepo and delete files on disc.

  ## Examples

      iex> delete_document(scope, document)
      {:ok, %Document{}}

      iex> delete_document(scope, document)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_document(Scope.t(), Document.t()) ::
          {:ok, Document.t()} | {:error, Ecto.Changeset.t()} | {:error, Oban.Job.changeset()}
  @dialyzer {:no_opaque, delete_document: 2}
  def delete_document(%Scope{} = scope, %Document{} = document) do
    true = document.user_id == scope.user.id
    files = Enum.map(document.files, fn file -> file.filepath end)

    results =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:delete, document)
      |> Oban.insert(:document_delete_job, fn %{delete: document} ->
        %{document_id: document.id}
        |> Workers.DeleteDocument.new()
      end)
      |> Oban.insert(:files_delete_job, fn _ ->
        %{files: files}
        |> Workers.DeleteFiles.new()
      end)
      |> Repo.transaction()

    case results do
      {:ok, %{delete: document}} -> {:ok, document}
      {:error, :document_delete_job, job, _} -> {:error, job}
      {:error, :files_delete_job, job, _} -> {:error, job}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(scope, document)
      %Ecto.Changeset{data: %Document{}}

  """
  @spec change_document(Scope.t(), Document.t()) :: Ecto.Changeset.t()
  @spec change_document(Scope.t(), Document.t(), map()) :: Ecto.Changeset.t()
  def change_document(%Scope{} = scope, %Document{} = document, attrs \\ %{}) do
    true = document.user_id == scope.user.id

    Document.changeset(document, attrs, scope)
  end

  # File ************************************************************************

  @doc """
  Get one file by id.
  """
  @spec get_file!(integer()) :: File.t()
  def get_file!(id) do
    Repo.get_by(File, id: id)
  end

  @doc """
  Delete a `%File{}` by id, remove from disc and SearchRepo.
  """
  @spec delete_file_by_id(integer()) ::
          {:ok, File.t()} | {:error, Ecto.Changeset.t() | Oban.Job.changeset()}
  @dialyzer {:no_opaque, delete_file_by_id: 1}
  def delete_file_by_id(id) do
    get_query = from f in File, where: f.id == ^id

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.one(:get, get_query)
      |> Ecto.Multi.delete(:delete, fn %{get: file} -> file end)
      |> Oban.insert(:job, fn %{delete: file} ->
        %{files: [file.filepath]}
        |> Workers.DeleteFiles.new()
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{get: _, delete: file, job: _}} -> {:ok, file}
      {:error, :delete, file, _} -> {:error, file}
      {:error, :job, job, _} -> {:error, job}
    end
  end
end

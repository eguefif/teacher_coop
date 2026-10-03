defmodule TeacherCoop.Discovery.Configuration do
  @moduledoc """
  Admin management of search indexes and engine configurations.
  """
  alias Phoenix.PubSub
  alias TeacherCoop.Repo
  alias TeacherCoop.Discovery.Configuration.{EngineConfiguration, Workers, Index}
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.SearchRepo

  # Index functions *********************************************************

  @doc """
  Subscribes to index updates (`{:index_updated, %Index{}}`).
  """
  @spec subscribe_index() :: :ok | {:error, term()}
  def subscribe_index() do
    PubSub.subscribe(TeacherCoop.PubSub, "index")
  end

  @spec broadcast(term()) :: :ok | {:error, term()}
  defp broadcast(message) do
    PubSub.broadcast(TeacherCoop.PubSub, "index", message)
  end

  @doc """
  Get one index by id.
  Use :bypass_auth to skip admin check
  """
  @spec get_index!(integer(), :bypass_auth | Scope.t()) :: Index.t()
  def get_index!(id, :bypass_auth) do
    Repo.get!(Index, id) |> Repo.preload(:engine_configuration)
  end

  def get_index!(id, current_scope) do
    true = Scope.is_admin?(current_scope)
    Repo.get!(Index, id) |> Repo.preload(:engine_configuration)
  end

  @doc """
  Get an index by names.
  """
  @spec get_index_by_uid(String.t(), :bypass_auth) :: Index.t()
  def get_index_by_uid(uid, :bypass_auth) do
    Repo.get_by!(Index, uid: uid) |> Repo.preload(:engine_configuration)
  end

  @doc """
  Set the given index to state indexing.
  Broadcast the new index if successful
  """
  @spec set_index_to_indexing(Index.t()) :: Index.t() | {:error, Ecto.Changeset.t()}
  def set_index_to_indexing(index) do
    with {:ok, index} <-
           Index.changeset_state(index, %{state: "indexing"})
           |> Repo.update() do
      broadcast({:index_updated, index})
      index
    end
  end

  @doc """
  Set the given index to state error_indexing.
  Broadcast the new index if successful
  """
  @spec set_index_to_error_indexing(Index.t()) :: Index.t() | {:error, Ecto.Changeset.t()}
  def set_index_to_error_indexing(index) do
    with {:ok, index} <-
           Index.changeset_state(index, %{state: "error_indexing"})
           |> Repo.update() do
      broadcast({:index_updated, index})
      index
    end
  end

  @doc """
  Set the given index to state indexed.
  Broadcast the new index if successful
  """
  @spec set_index_to_indexed(Index.t()) :: Index.t() | {:error, Ecto.Changeset.t()}
  def set_index_to_indexed(index) do
    with {:ok, index} <-
           Index.changeset_state(index, %{state: "indexed"})
           |> Repo.update() do
      broadcast({:index_updated, index})
      index
    end
  end

  @doc """
  Get index changeset.
  """
  @spec change_index(Scope.t(), Index.t()) :: Ecto.Changeset.t()
  @spec change_index(Scope.t(), Index.t(), map()) :: Ecto.Changeset.t()
  def change_index(%Scope{} = current_scope, %Index{} = index, attrs \\ %{}) do
    true = Scope.is_admin?(current_scope)
    Index.changeset(index, attrs, current_scope)
  end

  @doc """
  Returns all indexes with their engine configuration.
  """
  @spec list_index(Scope.t()) :: [Index.t()]
  def list_index(%Scope{} = scope) do
    true = Scope.is_admin?(scope)
    Repo.all(Index) |> Repo.preload(:engine_configuration)
  end

  @doc """
  Returns the fields of the documents search index.
  """
  @spec list_index_fields(Scope.t()) :: {:ok, [String.t()]} | list()
  def list_index_fields(%Scope{} = scope) do
    true = Scope.is_admin?(scope)
    SearchRepo.list_fields_for("documents")
  end

  @doc """
  Delete an index.
  """
  @spec delete_index(Index.t(), Scope.t()) ::
          {:ok, Index.t()} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def delete_index(%Index{} = index, %Scope{} = current_scope) do
    true = Scope.is_admin?(current_scope)

    case index.type != "original" do
      true -> Repo.delete(index)
      false -> {:error, "Index is an original index"}
    end
  end

  @doc """
  Inserts an index and enqueues its creation in the search engine.
  """
  @spec create_index(map(), Scope.t()) :: {:ok, Index.t()} | {:error, Ecto.Changeset.t()}
  def create_index(attrs, %Scope{} = current_scope) do
    true = Scope.is_admin?(current_scope)

    with {:ok, index} <-
           %Index{}
           |> Index.changeset(attrs, current_scope)
           |> Repo.insert() do
      %{"indexuid" => index.uid, "config_id" => index.engine_configuration_id}
      |> Workers.CreateIndex.new()
      |> Oban.insert()

      {:ok, index}
    end
  end

  @doc """
  Updates an index and enqueues its recreation in the search engine.
  """
  @spec update_index(Index.t(), map(), Scope.t()) ::
          {:ok, Index.t()} | {:error, Ecto.Changeset.t()}
  def update_index(%Index{} = params, attrs, %Scope{} = scope) do
    true = Scope.is_admin?(scope)

    with {:ok, index} <-
           params
           |> Index.changeset(attrs, scope)
           |> Repo.update() do
      %{"indexuid" => index.uid, "config_id" => index.engine_configuration_id}
      |> Workers.CreateIndex.new()
      |> Oban.insert()

      {:ok, index}
    end
  end

  # EngineConfiguration functions *********************************************************

  @doc """
  Get one configuration by id.
  Replace ```current_scope``` by ```:bypass_auth``` to skip auth check.
  Returns ```%EngineConfiguration{}```
  ## Example
    iex> get_configuration!(:bypass_auth, 5)
  """
  @spec get_configuration!(:bypass_auth | Scope.t(), integer()) :: EngineConfiguration.t()
  def get_configuration!(:bypass_auth, id) do
    Repo.get!(EngineConfiguration, id)
  end

  def get_configuration!(%Scope{} = current_scope, id) do
    true = Scope.is_admin?(current_scope)
    Repo.get!(EngineConfiguration, id)
  end

  @doc """
  Returns all the configurations from the table
  """
  @spec list_configurations(Scope.t()) :: [EngineConfiguration.t()]
  def list_configurations(%Scope{} = scope) do
    true = Scope.is_admin?(scope)
    Repo.all(EngineConfiguration)
  end

  @doc """
  Delete one configuration by id.
  """
  @spec delete_configuration(Scope.t(), EngineConfiguration.t()) ::
          {:ok, EngineConfiguration.t()} | {:error, Ecto.Changeset.t()}
  def delete_configuration(%Scope{} = user_scope, %EngineConfiguration{} = configuration) do
    true = Scope.is_admin?(user_scope)
    Repo.delete(configuration)
  end

  @doc """
  Insert a configuration in the Repo.
  """
  @spec create_configuration(Scope.t(), map()) ::
          {:ok, EngineConfiguration.t()} | {:error, Ecto.Changeset.t()}
  def create_configuration(%Scope{} = scope, attrs) do
    true = Scope.is_admin?(scope)

    %EngineConfiguration{}
    |> EngineConfiguration.changeset(attrs, scope)
    |> Repo.insert()
  end

  @doc """
  Update a configuration in the Repo.
  """
  @spec update_configuration(Scope.t(), EngineConfiguration.t(), map()) ::
          {:ok, EngineConfiguration.t()} | {:error, Ecto.Changeset.t()}
  def update_configuration(%Scope{} = scope, %EngineConfiguration{} = params, attrs) do
    true = Scope.is_admin?(scope)

    params
    |> EngineConfiguration.changeset(attrs, scope)
    |> Repo.update()
  end

  @doc """
  Returns a EngineConfiguration changeset.
  """
  @spec change_configuration(Scope.t(), EngineConfiguration.t()) :: Ecto.Changeset.t()
  @spec change_configuration(Scope.t(), EngineConfiguration.t(), map()) :: Ecto.Changeset.t()
  def change_configuration(
        %Scope{} = user_scope,
        %EngineConfiguration{} = configuration,
        attrs \\ %{}
      ) do
    true = configuration.user_id == user_scope.user.id

    EngineConfiguration.changeset(configuration, attrs, user_scope)
  end
end

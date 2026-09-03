defmodule TeacherCoop.Discovery.Configuration do
  alias Phoenix.PubSub
  alias TeacherCoop.Repo
  alias TeacherCoop.Discovery.Configuration.{EngineConfiguration, Workers, Index}
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.SearchRepo

  # Index functions *********************************************************

  def subscribe_index() do
    PubSub.subscribe(TeacherCoop.PubSub, "index")
  end

  defp broadcast(message) do
    PubSub.broadcast(TeacherCoop.PubSub, "index", message)
  end

  @doc """
  Get one index by id.
  Use :bypass_auth to skip admin check
  """
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
  def get_index_by_name!(name, :bypass_auth) do
    Repo.get_by!(Index, name: name) |> Repo.preload(:engine_configuration)
  end

  def set_index_to_indexing(index) do
    with {:ok, index} <-
           Index.changeset_state(index, %{state: "indexing"})
           |> Repo.update() do
      broadcast({:index_updated, index})
      index
    end
  end

  def set_index_to_error_indexing(index) do
    with {:ok, index} <-
           Index.changeset_state(index, %{state: "error_indexing"})
           |> Repo.update() do
      broadcast({:index_updated, index})
      index
    end
  end

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
  def change_index(%Index{} = index, %Scope{} = current_scope, attrs \\ %{}) do
    Index.changeset(index, attrs, current_scope)
  end

  def list_index(%Scope{} = scope) do
    true = Scope.is_admin?(scope)
    Repo.all(Index) |> Repo.preload(:engine_configuration)
  end

  def list_index_fields(%Scope{} = scope) do
    true = Scope.is_admin?(scope)
    SearchRepo.list_fields_for("documents")
  end

  @doc """
  Delete an index.
  """
  def delete_index(%Index{} = index, %Scope{} = current_scope) do
    true = Scope.is_admin?(current_scope)

    Repo.delete(index)
  end

  def create_index(attrs, %Scope{} = current_scope) do
    true = Scope.is_admin?(current_scope)

    with {:ok, index} <-
           %Index{}
           |> Index.changeset(attrs, current_scope)
           |> Repo.insert() do
      if not is_nil(index.engine_configuration_id) do
        %{"indexname" => index.name, "config_id" => index.engine_configuration_id}
        |> Workers.UpdateConfig.new()
        |> Oban.insert()
      end

      {:ok, index}
    end
  end

  def update_index(%Index{} = params, attrs, %Scope{} = scope) do
    true = Scope.is_admin?(scope)

    with {:ok, index} <-
           params
           |> Index.changeset(attrs, scope)
           |> Repo.update() do
      if not is_nil(index.engine_configuration_id) do
        %{"indexname" => index.name, "config_id" => index.engine_configuration_id}
        |> Workers.UpdateConfig.new()
        |> IO.inspect()
        |> Oban.insert()
      end

      {:ok, index}
    end
  end

  # EngineConfiguration functions *********************************************************

  @doc """
  Get one configuration by id.
  Replace ```current_scope``` by ```:bypass_auth``` to skip auth check.
  Returns ```{}Index```
  ## Example
    iex> get_configuration(:bypass_auth, 5)
  """
  def get_configuration!(:bypass_auth, id) do
    Repo.get!(EngineConfiguration, id)
  end

  def get_configuration!(current_scope, id) do
    true = Scope.is_admin?(current_scope)
    Repo.get!(EngineConfiguration, id)
  end

  @doc """
  Returns all the configurations from the table
  """
  def list_configurations(%Scope{} = scope) do
    true = Scope.is_admin?(scope)
    Repo.all(EngineConfiguration)
  end

  @doc """
  Delete one configuration by id.
  """
  def delete_configuration(user_scope, %EngineConfiguration{} = configuration) do
    true = Scope.is_admin?(user_scope)
    Repo.delete(configuration)
  end

  @doc """
  Insert a configuration in the Repo.
  """
  def create_configuration(%Scope{} = scope, attrs) do
    true = Scope.is_admin?(scope)

    with {:ok, configuration} <-
           %EngineConfiguration{}
           |> EngineConfiguration.changeset(attrs, scope)
           |> Repo.insert() do
      if not is_nil(configuration.index_names) do
        Enum.each(configuration.index_names, fn indexname ->
          %{"indexname" => indexname, "config_id" => configuration.id}
          |> Workers.UpdateConfig.new()
          |> Oban.insert()
        end)
      end

      {:ok, configuration}
    end
  end

  @doc """
  Update a configuration in the Repo.
  """
  def update_configuration(%Scope{} = scope, %EngineConfiguration{} = params, attrs) do
    true = Scope.is_admin?(scope)

    with {:ok, configuration} <-
           params
           |> EngineConfiguration.changeset(attrs, scope)
           |> Repo.update() do
      if not is_nil(configuration.index_names) do
        Enum.each(configuration.index_names, fn indexname ->
          %{"indexname" => indexname, "config_id" => configuration.id}
          |> Workers.UpdateConfig.new()
          |> Oban.insert()
        end)
      end

      {:ok, configuration}
    end
  end

  @doc """
  Returns a EngineConfiguration changeset.
  """
  def change_configuration(
        %Scope{} = user_scope,
        %EngineConfiguration{} = configuration,
        attrs \\ %{}
      ) do
    true = configuration.user_id == user_scope.user.id

    EngineConfiguration.changeset(configuration, attrs, user_scope)
  end
end

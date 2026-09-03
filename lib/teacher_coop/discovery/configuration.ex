defmodule TeacherCoop.Discovery.Configuration do
  alias TeacherCoop.Repo
  alias TeacherCoop.Discovery.Configuration.{EngineConfiguration, Workers, Index}
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.SearchRepo

  @doc """
  Get one configuration by id.
  """
  def get_configuration!(id) do
    Repo.get!(EngineConfiguration, id)
  end

  @doc """
  Delete one configuration by id.
  """
  def delete_configuration(user_scope, %EngineConfiguration{} = configuration) do
    true = Scope.is_admin?(user_scope)
    Repo.delete(configuration)
  end

  @doc """
  Returns all the configurations from the table
  """
  def list_configurations() do
    Repo.all(EngineConfiguration)
  end

  def list_index_names() do
    Repo.all(Index) |> Repo.preload(:engine_configuration)
  end

  def list_index_fields() do
    SearchRepo.list_fields_for("documents")
  end

  @doc """
  Insert a configuration in the Repo.
  """
  def create_configuration(%Scope{} = scope, attrs) do
    true = Scope.is_admin?(scope)

    with {:ok, configuration} <-
           %EngineConfiguration{}
           |> EngineConfiguration.changeset(attrs, scope)
           |> IO.inspect()
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

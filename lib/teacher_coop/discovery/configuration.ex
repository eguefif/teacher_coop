defmodule TeacherCoop.Discovery.Configuration do
  alias TeacherCoop.Repo
  alias TeacherCoop.Discovery.Configuration.EngineConfiguration
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.SearchRepo

  @doc """
  Get one configuration by id.
  """
  def get_configuration!(id) do
    Repo.get!(EngineConfiguration, id)
  end

  @doc """
  Returns all the configurations from the table
  """
  def list_configurations() do
    Repo.all(EngineConfiguration)
  end

  @doc """
  Insert a configuration in the Repo.
  """
  def create_configuration(%Scope{} = scope, attrs) do
    true = Scope.is_admin(scope)

    with {:ok, configuration} <-
           %EngineConfiguration{}
           |> EngineConfiguration.changeset(attrs, scope)
           |> Repo.insert() do
      if not is_nil(configuration.index_name) do
        # TODO: put that in a background job
        SearchRepo.set_index(configuration.index_name, configuration.config)
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

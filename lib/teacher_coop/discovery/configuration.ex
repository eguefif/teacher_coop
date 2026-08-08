defmodule TeacherCoop.Discovery.Configuration do
  alias TeacherCoop.Repo
  alias TeacherCoop.Discovery.Configuration.EngineConfiguration
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.SearchRepo

  def list_configurations() do
    Repo.all(EngineConfiguration)
  end

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

      configuration
    end
  end
end

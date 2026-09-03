defmodule TeacherCoop.Discovery.Configuration.Workers.UpdateConfig do
  @moduledoc """
  Worker that updates an index's config on Meilisearch.
  """
  use Oban.Worker

  alias TeacherCoop.SearchRepo
  alias TeacherCoop.Discovery.Configuration

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    configuration = Configuration.get_configuration!(:bypass_auth, args["config_id"]).config

    index =
      Configuration.get_index_by_name!(args["indexname"], :bypass_auth)
      |> Configuration.set_index_to_indexing()

    case SearchRepo.set_index(args["indexname"], Ecto.embedded_dump(configuration, :json)) do
      :ok ->
        Configuration.set_index_to_indexed(index)
        :ok

      value ->
        Configuration.set_index_to_error_indexing(index)
        {:error, value}
    end
  end
end

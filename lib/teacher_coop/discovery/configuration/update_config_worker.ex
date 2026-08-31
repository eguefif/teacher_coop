defmodule TeacherCoop.Discovery.Configuration.Workers.UpdateConfig do
  @moduledoc """
  Worker that updates an index's config on Meilisearch.
  """
  use Oban.Worker,
    unique: true

  alias TeacherCoop.SearchRepo
  alias TeacherCoop.Discovery.Configuration

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    configuration = Configuration.get_configuration!(args["config_id"]).config

    case SearchRepo.set_index(args["indexname"], Ecto.embedded_dump(configuration, :json)) do
      :ok -> :ok
      _ -> :error
    end
  end
end

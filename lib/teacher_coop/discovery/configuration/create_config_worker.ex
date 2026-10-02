defmodule TeacherCoop.Discovery.Configuration.Workers.CreateIndex do
  @moduledoc """
  Worker that updates an index's config on Meilisearch.
  """
  use Oban.Worker

  alias TeacherCoop.SearchRepo
  alias TeacherCoop.Discovery.Configuration

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    indexuid = args["indexuid"]
    configuration = args["config_id"]

    index =
      Configuration.get_index_by_uid(indexuid, :bypass_auth)
      |> Configuration.set_index_to_indexing()

    with :ok <- SearchRepo.create_index(indexuid, "id"),
         :ok <- update_config(indexuid, configuration) do
      Configuration.set_index_to_indexed(index)
      :ok
    else
      :error ->
        Configuration.set_index_to_error_indexing(index)
        {:error, "Impossible to create index"}
    end
  end

  defp update_config(_, config) when is_nil(config), do: :ok

  defp update_config(indexuid, configuration) do
    configuration = Configuration.get_configuration!(:bypass_auth, configuration).config

    SearchRepo.update_index_settings(
      indexuid,
      Ecto.embedded_dump(configuration, :json)
    )
  end
end

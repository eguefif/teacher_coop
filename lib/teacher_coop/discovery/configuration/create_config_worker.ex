defmodule TeacherCoop.Discovery.Configuration.Workers.CreateIndex do
  @moduledoc """
  Worker that updates an index's config on Meilisearch.
  """
  use Oban.Worker

  alias TeacherCoop.SearchRepo
  alias TeacherCoop.Discovery.Configuration
  alias TeacherCoop.Discovery.Configuration.Index

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    indexuid = args["indexuid"]
    configuration = args["config_id"]

    with {:ok, index} <- set_index_to_indexing(indexuid),
         :ok <- SearchRepo.create_index(indexuid, "id"),
         :ok <- update_config(indexuid, configuration) do
      Configuration.set_index_to(index, "indexed")
      :ok
    else
      :error ->
        set_index_to_error(indexuid)
        {:error, "Impossible to update config for index: #{indexuid}"}
    end
  end

  @spec set_index_to_error(String.t()) :: {:ok, Index.t()} | {:error, Ecto.Changeset.t()}
  defp set_index_to_error(indexuid) do
    Configuration.get_index_by_uid!(indexuid, :bypass_auth)
    |> Configuration.set_index_to("error_indexing")
  end

  @spec set_index_to_indexing(String.t()) :: {:ok, Index.t()} | {:error, Ecto.Changeset.t()}
  defp set_index_to_indexing(indexuid) do
    Configuration.get_index_by_uid!(indexuid, :bypass_auth)
    |> Configuration.set_index_to("indexing")
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

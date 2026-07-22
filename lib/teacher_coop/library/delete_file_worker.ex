defmodule TeacherCoop.Library.Workers.DeleteFiles do
  use Oban.Worker,
    queue: :document_ingestion,
    unique: true

  @static_file_path "/priv/static/"

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    base_path = File.cwd!() <> @static_file_path

    result =
      args["files"]
      |> Enum.map(fn file -> base_path <> file end)
      |> Enum.filter(fn file -> File.exists?(file) end)
      |> Enum.map(fn file -> File.rm(file) end)
      |> Enum.all?(fn result -> result == :ok end)

    if result == true do
      :ok
    else
      :error
    end
  end
end

defmodule TeacherCoop.Library.Workers.DeleteDocument do
  @moduledoc """
  Remove a document from SearchRepo
  """
  use Oban.Worker,
    queue: :document_ingestion,
    unique: true

  alias TeacherCoop.SearchRepo.SearchDocuments

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    case SearchDocuments.delete_document(args["document_id"]) do
      :ok -> :ok
      _ -> :error
    end
  end
end

defmodule TeacherCoop.Library.Workers.IndexDocument do
  @moduledoc """
  Index a document in SearchRepo
  """
  use Oban.Worker,
    queue: :document_ingestion,
    unique: true

  alias TeacherCoop.SearchRepo.SearchDocuments

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    case SearchDocuments.index_document(args["attrs"]) do
      :ok -> :ok
      _ -> :error
    end
  end
end

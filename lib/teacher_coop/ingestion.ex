defmodule TeacherCoop.Ingestion do
  # TODO:
  # - [ ] Work on chunking, it seems that chunk_every won't do the job, be sure of that.
  def ingest_documents(documents \\ []) when is_list(documents) do
    documents
    |> Stream.map(&to_text/1)
    |> Stream.chunk_every(100, 75)
    |> Enum.map(&IO.inspect/1)
  end

  def to_text(document) do
    content =
      with {:ok, data} <- PdfExtractor.extract_text(document) do
        data
        |> Map.values()
        |> Enum.join()
      end

    %{filename: document, content: content}
  end
end

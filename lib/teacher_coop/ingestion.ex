defmodule TeacherCoop.Ingestion do
  alias TeacherCoop.Ingestion.Embeddings
  alias TeacherCoop.Ingestion.LLMPreprocessing

  # TODO: storing in Meilisearch
  # - [ ] Remove embeddings part in
  # - [ ] Configure embedders in the Meilisearch set up part
  # - [ ] Store each chunks in the db
  # - [ ] Next iteration: need to pass a list of files to ingest_documents
  # - [ ] Create a File resource in Library

  # AI assisted search
  # Try to find a tiny model with Ollama, spin up a Scale way GPU to try it and plug
  # with this project. The goal is to create three things:
  # - [ ] a summary: used as both embeddings and vector search
  # - [ ] Content: these snippets will be used as chunked and embeddings
  # - [ ] Keywords to use as tags.
  # - [ ] The goal will be to use a small model in the end.

  def ingest_documents(documents \\ []) when is_list(documents) do
    documents
    |> Stream.map(&to_text/1)
    |> Stream.map(&llm_preprocess/1)
    # |> Stream.map(&chunk/1)
    # |> Stream.map(&embeds/1)
    |> Enum.map(&load/1)
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

  def chunk(%{filename: filename, content: content} = _) do
    chunks =
      TextChunker.split(content, chunk_size: 200, chunk_overlap: 25)
      |> Enum.map(& &1.text)

    %{filename: filename, chunks: chunks}
  end

  def embeds(%{filename: filename, chunks: chunks} = _) do
    embeddings = Embeddings.embed(chunks)
    %{filename: filename, embeddings: embeddings}
  end

  def load(documents) do
    IO.inspect(documents)
  end

  def llm_preprocess(%{filename: filename, content: content} = _) do
    content = LLMPreprocessing.preprocess(content)
    %{filename: filename, content: content}
  end
end

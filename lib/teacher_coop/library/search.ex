defmodule TeacherCoop.Library.Search do
  alias TeacherCoop.Library.Document

  @moduledoc """
  Sub Library context for search.

  We use Meilisearch, this context allows for indexing/searching documents.
  """

  @doc """
  Index a document in Meilisearch
  """
  def index_document(%Document{} = document) do
    # TODO: Should happend in a background job with retry. We want to make sure it happens
    # Meilisearch indexes document asynchrounously, we need to check if it worked.
    # Potential strategy:
    # 1. start trying indexing here
    # 2. Schedule a check job with task_details and retry mechanism
    # 3. Keep track in the document database to know if a document was indexed or in a table
    client = Meilisearch.client(:meilisearch)

    meilisearch_attrs = %{
      uid: document.id,
      title: document.title,
      description: document.description
    }

    case Meilisearch.Document.create_or_replace(client, "documents", meilisearch_attrs) do
      {:ok, _} -> :ok
      {:error, _task_details} -> :error
    end
  end
end

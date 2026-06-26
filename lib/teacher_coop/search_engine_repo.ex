defmodule TeacherCoop.SearchEngineRepo do
  @moduledoc """
  This module is a layer between the Search Engine and the application.
  It handles indexing document and search.
  It uses the Document struct as an input for indexing.
  """

  alias TeacherCoop.Library.Document

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
      {:ok, _task = %Meilisearch.SummarizedTask{taskUid: _taskUid}} -> :ok
      {:error, _error_details} -> :error
    end
  end
end

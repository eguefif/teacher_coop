defmodule TeacherCoop.Library do
  @moduledoc """
  The Library context.
  The Library handles documents in two ways:
    - CRUDE operations handled by the sub context Library.Documents
    - Search operations handled by the sub context Library.Search
  """

  alias TeacherCoop.Library.{Documents, Search}
  alias TeacherCoop.Library.Document

  def create_document(scope, attrs \\ %{}) do
    with {:ok, document = %Document{}} <- Documents.create_document(scope, attrs),
         :ok <- Search.index_document(document) do
      {:ok, document}
    end
  end

  # Delegates functions for CRUDE operations ****************************************

  defdelegate subscribe_documents(scope), to: Documents
  defdelegate list_documents(scope), to: Documents
  defdelegate get_document!(scope, id), to: Documents
  defdelegate update_document(scope, document, attrs \\ %{}), to: Documents
  defdelegate delete_document(scope, document), to: Documents
  defdelegate change_document(scope, document, attrs \\ %{}), to: Documents

  # Delegates functions for search operations ***************************************
end

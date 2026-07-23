defmodule TeacherCoop.SearchRepo.SearchDocuments do
  import TeacherCoop.SearchRepo
  alias TeacherCoop.Library.Document
  alias TeacherCoop.Repo
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Discovery.SearchResult

  @doc """
  Delete a document from Meilisearch
  """
  def delete_document(document_id) do
    case Meilisearch.Document.delete_one(get_client(), index_name("documents"), document_id) do
      {:ok, %Meilisearch.SummarizedTask{} = task} ->
        wait_for_tasks([task])
        :ok

      {:error, _error_details} ->
        :error
    end
  end

  @doc """
  Index a document in Meilisearch
  """
  def index_document(%{} = attrs) do
    case Meilisearch.Document.create_or_replace(get_client(), index_name("documents"), attrs) do
      {:ok, %Meilisearch.SummarizedTask{} = task} ->
        wait_for_tasks([task])
        :ok

      {:error, _error_details} ->
        :error
    end
  end

  def create_attributes_from_document(%Scope{} = scope, %Document{} = document) do
    objectives_field = create_objectives_field(document.objectives)

    Map.from_struct(document)
    |> Map.filter(&(elem(&1, 0) != :__meta__))
    |> Map.filter(&(elem(&1, 0) != :files))
    |> Map.filter(&(elem(&1, 0) != :objectives))
    |> Map.filter(&(elem(&1, 0) != :document_objectives))
    |> Map.put(:objectives, objectives_field)
    |> Map.put(:user_id, scope.user.id)
    |> Map.put(:email, scope.user.email)
    |> Map.put(:fullname, scope.user.fullname)
  end

  defp create_objectives_field(objectives) do
    objectives
    |> Enum.map(& &1.goal)
    |> Enum.join(" ")
  end

  @doc """
  Update documents user info for all the user's document in the NoSQLDB
  """
  def update_user_info_for_documents(user) do
    client = get_client()

    users_documents =
      Repo.all_by(Document, user_id: user.id)
      |> Enum.map(&Map.from_struct(&1))
      |> Enum.map(&Map.filter(&1, fn m -> elem(m, 0) != :files end))
      |> Enum.map(&Map.filter(&1, fn m -> elem(m, 0) != :objectives end))
      |> Enum.map(&Map.filter(&1, fn m -> elem(m, 0) != :document_objectives end))
      |> Enum.map(&Map.filter(&1, fn m -> elem(m, 0) != :__meta__ end))
      |> Enum.map(&Map.merge(&1, %{email: user.email, fullname: user.fullname}))

    case Meilisearch.Document.create_or_update(client, index_name("documents"), users_documents) do
      {:ok, task = %Meilisearch.SummarizedTask{}} ->
        wait_for_tasks([task])
        :ok

      {:error, error} ->
        {:ok, error}
    end
  end

  @doc """
  Specialized function to look into documents
  """
  def search_document(search_terms) when is_bitstring(search_terms) do
    client = get_client()

    case Meilisearch.Search.search(client, index_name("documents"), q: search_terms) do
      {:ok, response} ->
        {:ok, create_search_result(response)}

      _ ->
        :error
    end
  end

  defp create_search_result(result) when is_map(result) do
    %SearchResult{
      facets: %{},
      hits: result.hits
    }
  end

  @doc """
  Get all the documents related to a user
  """
  def get_user_documents(user) do
    client = get_client()

    Meilisearch.Document.list(client, index_name("documents"), filter: "user_id=#{user.id}")
  end
end

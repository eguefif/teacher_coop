defmodule TeacherCoop.SearchRepo.SearchDocuments do
  import TeacherCoop.SearchRepo
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Library.Document
  alias TeacherCoop.Repo

  @doc """
  Index a document in Meilisearch
  """
  def index_document(%Scope{} = scope, %Document{} = document) do
    attrs =
      Map.from_struct(document)
      |> Map.filter(&(elem(&1, 0) != :__meta__))
      |> Map.filter(&(elem(&1, 0) != :files))
      |> Map.put(:user_id, scope.user.id)
      |> Map.put(:email, scope.user.email)
      |> Map.put(:fullname, scope.user.fullname)

    case Meilisearch.Document.create_or_replace(get_client(), index_name("documents"), attrs) do
      {:ok, %Meilisearch.SummarizedTask{} = task} ->
        wait_for_tasks([task])
        :ok

      {:error, _error_details} ->
        :error
    end
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

  @doc """
  Get all the documents related to a user
  """
  def get_user_documents(user) do
    client = get_client()

    Meilisearch.Document.list(client, index_name("documents"), filter: "user_id=#{user.id}")
  end
end

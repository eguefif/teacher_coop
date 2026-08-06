defmodule TeacherCoop.Discovery do
  @moduledoc """
  The Discovery context handles user search operations and search evaluation.
  When a user do a search, it uses SearchRepo to make the search. It also uses
  Repo to register a new search and track performance and user satisfaction. 
  We want to be able to improve our serach engine.
  """

  import Ecto.Query, warn: false
  alias TeacherCoop.Repo
  alias TeacherCoop.SearchRepo.SearchDocuments

  alias TeacherCoop.Discovery.Search
  alias TeacherCoop.Library
  alias TeacherCoop.Accounts.Scope

  @doc """
  Returns the list of searches.

  ## Examples

      iex> list_searches(scope)
      [%Search{}, ...]

  """
  def list_searches(%Scope{} = scope) do
    Repo.all_by(Search, user_id: scope.user.id)
  end

  @doc """
  Gets a single search.

  Raises `Ecto.NoResultsError` if the Search does not exist.

  ## Examples

      iex> get_search!(scope, 123)
      %Search{}

      iex> get_search!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_search!(%Scope{} = scope, id) do
    Repo.get_by!(Search, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a search.

  ## Examples

      iex> create_search(scope, %{field: value})
      {:ok, %Search{}}

      iex> create_search(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_search(%Scope{} = _scope, %{search_terms: search_terms} = _) do
    # %Search{}
    # |> Search.changeset(attrs, scope)
    # |> Repo.insert()
    make_search(search_terms)
    |> get_db_results()
    |> reorder_db_results()
  end

  def create_search(nil, %{search_terms: search_terms} = _) do
    # %Search{}
    # |> Search.changeset(attrs, scope)
    # |> Repo.insert()
    make_search(search_terms)
    |> get_db_results()
    |> reorder_db_results()
  end

  defp make_search(search_terms) do
    SearchDocuments.search_document(search_terms)
  end

  defp get_db_results({:ok, results}) do
    db_results =
      results.hits
      |> Enum.map(& &1["id"])
      |> Library.list_documents_by_ids()

    {results.hits, db_results}
  end

  defp reorder_db_results({results, db_results}) do
    results
    |> Enum.map(fn result ->
      Enum.find(db_results, &(&1.id == result["id"]))
    end)
  end

  @doc """
  Deletes a search.

  ## Examples

      iex> delete_search(scope, search)
      {:ok, %Search{}}

      iex> delete_search(scope, search)
      {:error, %Ecto.Changeset{}}

  """
  def delete_search(%Scope{} = scope, %Search{} = search) do
    true = search.user_id == scope.user.id

    Repo.delete search do
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking search changes.

  ## Examples

      iex> change_search(scope, search)
      %Ecto.Changeset{data: %Search{}}

  """
  def change_search(%Scope{} = scope, %Search{} = search, attrs \\ %{}) do
    true = search.user_id == scope.user.id

    Search.changeset(search, attrs, scope)
  end
end

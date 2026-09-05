defmodule TeacherCoop.Discovery do
  @moduledoc """
  The Discovery context handles user search operations and search evaluation.
  When a user do a search, it uses SearchRepo to make the search. It also uses
  Repo to register a new search and track performance and user satisfaction. 
  We want to be able to improve our serach engine.
  """

  alias TeacherCoop.Repo
  alias TeacherCoop.SearchRepo
  alias TeacherCoop.SearchRepo.SearchDocuments

  alias TeacherCoop.Discovery.{Search, SearchSession}
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
  Create a search session with initial values.
  A search session allows the app to track a user's search
  through different searches in the same time window.
  """
  def create_search_session(scope) do
    SearchSession.new(scope, SearchRepo.get_document_index_test_a_b())
  end

  def save_successful_search(
        %SearchSession{created_at: %DateTime{} = created_at} = search_session,
        click_position
      ) do
    attrs = %{
      success_click_position: click_position,
      dwell_time: DateTime.diff(created_at, DateTime.utc_now(), :millisecond),
      success: true
    }

    search_session.search_record
    |> Search.changeset(attrs, search_session.scope)
    |> Repo.update()
  end

  @doc """
  Creates a search using a SearchSession.

  ## Examples

      iex> create_search(search_session)
      %SearchSession{}}

  """
  def handle_search(%SearchSession{} = search_session, search_terms) do
    search_session
    |> update_current_search()
    |> make_search(search_terms)
    |> create_search_record()
  end

  # If search_record nil, we create a new one
  def update_current_search(%SearchSession{} = search_session)
      when is_nil(search_session.search_record), do: search_session

  # If not it means the user is makeing a new search, we mark
  # the current one as failed and update the search record
  def update_current_search(
        %SearchSession{
          created_at: %DateTime{} = created_at,
          scope: scope,
          search_record: %Search{} = search_record
        } = search_session
      ) do
    attrs = %{
      sucess: false,
      dwell_time: DateTime.diff(created_at, DateTime.utc_now(), :millisecond)
    }

    search_record
    |> Search.changeset(attrs, scope)
    |> Repo.update()

    %SearchSession{search_session | search_record: nil}
  end

  defp make_search(%SearchSession{} = search_session, search_terms) do
    search_session = SearchSession.add_search_terms(search_session, search_terms)

    {results, db_results} =
      SearchDocuments.search_document(search_terms)
      |> get_db_results()
      |> reorder_db_results()

    SearchSession.add_search_results(search_session, results, db_results)
  end

  defp get_db_results({:ok, results}) do
    db_results =
      results.hits
      |> Enum.map(& &1["id"])
      |> Library.list_documents_by_ids()

    {results, db_results}
  end

  defp reorder_db_results({results, db_results}) do
    db_results =
      results.hits
      |> Enum.map(fn result ->
        Enum.find(db_results, &(&1.id == result["id"]))
      end)

    {results, db_results}
  end

  defp create_search_record(%SearchSession{} = search_session) do
    attrs = %{
      hits_count: length(search_session.results.hits),
      session_id: search_session.session_id,
      document_index: search_session.document_index
    }

    search_record =
      %Search{}
      |> Search.changeset(attrs, search_session.scope)
      |> Repo.insert()

    SearchSession.add_search_record(search_session, search_record)
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

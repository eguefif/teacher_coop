defmodule TeacherCoop.Discovery do
  @moduledoc """
  The Discovery context handles user search operations and search evaluation.
  When a user do a search, it uses SearchRepo to make the search. It also uses
  Repo to register a new search and track performance and user satisfaction. 
  We want to be able to improve our serach engine.
  """

  alias TeacherCoop.Repo
  # alias TeacherCoop.SearchRepo
  # alias TeacherCoop.SearchRepo.SearchDocuments

  alias TeacherCoop.Discovery.{Search, SearchSession}
  # alias TeacherCoop.Library
  alias TeacherCoop.Accounts.Scope

  @doc """
  Create one search session in `searching` state.
  A Session is used to track a user over multiple search queries.
  """
  def create_search_session(scope) do
    %SearchSession{}
    |> SearchSession.changeset(%{state: "searching"}, scope)
    |> Repo.insert()
  end

  @doc """
  Get one search session or raise an exception.
  """
  def get_search_session!(id) do
    Repo.get!(SearchSession, id)
    |> Repo.preload(:user)
  end

  @doc """
  Returns a %SearchSession{}` `Changeset`.
  """
  def change_search_session(attrs \\ %{}, scope) do
    %SearchSession{}
    |> SearchSession.changeset(attrs, scope)
  end

  @doc """
  Get one search or raise an exception.
  """
  def get_search!(id) do
    Repo.get!(Search, id)
    |> Repo.preload(:user)
  end

  @doc """
  Create a search.
  A search is one query typed by the user on the search engine page.
  """
  def create_search(%SearchSession{} = search_session, attrs \\ %{}, %Scope{} = scope) do
    %Search{}
    |> Search.changeset(attrs, search_session, scope)
    |> Repo.insert()
  end

  @doc """
  Returns a %Search{}` `Changeset`.
  """
  def change_search(search_session, attrs \\ %{}, %Scope{} = scope) do
    %Search{}
    |> Search.changeset(attrs, search_session, scope)
  end

  @doc """
  Handle a search for the user.
  """
  def handle_search(search_terms \\ "", scope, search_session \\ nil)

  def handle_search(
        search_terms,
        scope,
        search_session
      )
      when is_binary(search_terms) and is_nil(search_session) do
    {:ok, search_session} = create_search_session(scope)
    {search, hits} = do_search(search_session, search_terms, scope)
    {search_session, search, hits}
  end

  def handle_search(
        search_terms,
        scope,
        search_session
      )
      when is_binary(search_terms) do
    {search, hits} = do_search(search_session, search_terms, scope)

    {search_session, search, hits}
  end

  defp do_search(search_session, search_terms, scope) do
    results = []

    search_attrs = %{
      search_terms: search_terms,
      hits_count: length(results)
    }

    {:ok, search} = create_search(search_session, search_attrs, scope)
    {search, results}
  end
end

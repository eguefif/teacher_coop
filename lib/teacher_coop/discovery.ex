defmodule TeacherCoop.Discovery do
  @moduledoc """
  The Discovery context handles user search operations and search evaluation.
  When a user do a search, it uses SearchRepo to make the search. It also uses
  Repo to register a new search and track performance and user satisfaction. 
  We want to be able to improve our serach engine.
  """

  alias TeacherCoop.Repo
  alias TeacherCoop.SearchRepo.SearchDocuments

  alias TeacherCoop.Discovery.{Search, SearchSession}
  alias TeacherCoop.Library

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
  def create_search(%SearchSession{} = search_session, attrs \\ %{}, scope) do
    %Search{}
    |> Search.changeset(attrs, search_session, scope)
    |> Repo.insert()
  end

  @doc """
  Update a search
  """
  def update_search(%Search{} = search, attrs \\ %{}, scope, search_session) do
    search
    |> Search.changeset(attrs, search_session, scope)
    |> Repo.update()
  end

  @doc """
  Returns a %Search{}` `Changeset`.
  """
  def change_search(search_session, attrs \\ %{}, scope) do
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
    {search, db_hits, engine_hits} = do_search(search_session, search_terms, scope)
    {search_session, search, db_hits, engine_hits}
  end

  def handle_search(
        search_terms,
        scope,
        search_session
      )
      when is_binary(search_terms) do
    {search, db_hits, engine_hits} = do_search(search_session, search_terms, scope)

    {search_session, search, db_hits, engine_hits}
  end

  defp do_search(search_session, search_terms, scope) do
    {db_hits, engine_hits} =
      with {:ok, engine_hits} <- SearchDocuments.search_documents(search_terms),
           {:ok, {db_hits, engine_hits}} <-
             get_db_document_from_engine_hits(engine_hits) do
        {db_hits, engine_hits}
      end

    search_attrs = %{
      search_terms: search_terms,
      hits_count: length(db_hits)
    }

    {:ok, search} = create_search(search_session, search_attrs, scope)
    {search, db_hits, engine_hits}
  end

  defp get_db_document_from_engine_hits(engine_hits) do
    db_hits =
      engine_hits.hits
      |> Enum.map(& &1["id"])
      |> then(&Library.list_documents_by_ids(&1))
      |> reorder_db_hits(engine_hits.hits)

    {:ok, {db_hits, engine_hits}}
  end

  defp reorder_db_hits(db_hits, engine_hits) do
    engine_hits
    |> Enum.map(&Enum.find(db_hits, fn result -> result.id == &1["id"] end))
  end

  @doc """
  Mark a search as successfull.
  """
  def mark_search_as_succes(%Search{} = search, click_position, scope, search_session) do
    search
    |> update_search(
      %{success_click_position: click_position, state: "success"},
      scope,
      search_session
    )
  end
end

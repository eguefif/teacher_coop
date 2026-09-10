defmodule TeacherCoop.Discovery do
  @moduledoc """
  The Discovery context handles user search operations and search evaluation.
  When a user do a search, it uses SearchRepo to make the search. It also uses
  Repo to register a new search and track performance and user satisfaction. 
  We want to be able to improve our serach engine.
  """

  alias TeacherCoop.Repo
  alias TeacherCoop.SearchRepo.SearchDocuments

  alias TeacherCoop.Discovery.Search
  alias TeacherCoop.Library

  @doc """
  Get a search by it search terms.
  Params: `search_terms: string`
  """
  def get_search_by_search_terms!(search_terms) do
    Repo.get_by!(Search, search_terms: search_terms)
  end

  @doc """
  Create a search.
  A search is one query typed by the user on the search engine page.
  """
  def create_search(%{} = attrs, scope) do
    %Search{}
    |> Search.changeset(attrs, scope)
    |> Repo.insert()
  end

  @doc """
  Update a search
  """
  def update_search(%Search{} = search, attrs \\ %{}, scope) do
    search
    |> Search.changeset(attrs, scope)
    |> Repo.update()
  end

  @doc """
  Returns a %Search{}` `Changeset`.
  """
  def change_search(attrs \\ %{}, scope) do
    %Search{}
    |> Search.changeset(attrs, scope)
  end

  @doc """
  Handle a search for the user.
  """
  def handle_search(search_terms \\ "", scope, search_session \\ nil)

  def handle_search(search_terms, scope, search_session) when search_terms == "" do
    {:error,
     change_search(%{search_terms: search_terms, search_session_id: search_session}, scope), [],
     []}
  end

  def handle_search(
        search_terms,
        scope,
        search_session
      )
      when is_binary(search_terms) do
    {search, db_hits, engine_hits} = do_search(search_session, search_terms, scope)

    {:ok, search, db_hits, engine_hits}
  end

  defp do_search(search_session, search_terms, scope) do
    with {:ok, engine_hits} <- SearchDocuments.search_documents(search_terms),
         {:ok, {db_hits, engine_hits}} <-
           get_db_document_from_engine_hits(engine_hits),
         {:ok, search} <- do_create_search(search_terms, length(db_hits), search_session, scope) do
      {search, db_hits, engine_hits}
    end
  end

  defp do_create_search(search_terms, db_hits_count, search_session, scope) do
    search_attrs = %{
      search_terms: search_terms,
      hits_count: db_hits_count,
      search_session_id: search_session
    }

    create_search(search_attrs, scope)
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
  def mark_search_as_succes(%Search{} = search, click_position, scope, search_session, reason) do
    search
    |> update_search(
      %{
        success_click_position: click_position,
        state: "success",
        reason: reason,
        search_session_id: search_session
      },
      scope
    )
  end
end

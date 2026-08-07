defmodule TeacherCoop.Discovery.SearchSession do
  defstruct [
    :session_id,
    :created_at,
    :results,
    :db_results,
    :scope,
    :search_record,
    :search_terms,
    :document_index
  ]

  def new(scope, document_index) do
    %__MODULE__{
      scope: scope,
      session_id: Ecto.UUID.generate(version: 7),
      created_at: DateTime.utc_now(),
      results: nil,
      db_results: [],
      document_index: document_index,
      search_record: nil
    }
  end

  def get_hits(%__MODULE__{} = search_session) do
    search_session.results.hits
  end

  def add_search_terms(%__MODULE__{} = search_session, search_terms) do
    %__MODULE__{search_session | search_terms: search_terms}
  end

  def add_search_results(%__MODULE__{} = search_session, results, db_results) do
    %__MODULE__{search_session | results: results, db_results: db_results}
  end

  def add_search_record(%__MODULE__{} = search_session, search_record) do
    %__MODULE__{search_session | search_record: search_record}
  end
end

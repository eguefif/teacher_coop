defmodule TeacherCoop.Discovery do
  @moduledoc """
  The Discovery context handles user search operations and search evaluation.
  When a user do a search, it uses SearchRepo to make the search. It also uses
  Repo to register a new search and track performance and user satisfaction. 
  We want to be able to improve our serach engine.
  """

  # alias TeacherCoop.Repo
  # alias TeacherCoop.SearchRepo
  # alias TeacherCoop.SearchRepo.SearchDocuments

  alias TeacherCoop.Discovery.{Search, SearchSession}
  # alias TeacherCoop.Library
  # alias TeacherCoop.Accounts.Scope

  def create_search_session(scope) do
    %SearchSession{}
    |> SearchSession.changeset(%{state: "searching"}, scope)
  end
end

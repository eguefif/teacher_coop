defmodule TeacherCoop.Dashboard do
  alias TeacherCoop.Repo
  alias TeacherCoop.Library.Document
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Accounts.User

  alias TeacherCoop.Discovery.Search.Query

  def documents_count(scope) do
    true = Scope.is_admin?(scope)
    Repo.aggregate(Document, :count)
  end

  def users_count(scope) do
    true = Scope.is_admin?(scope)
    Repo.aggregate(User, :count)
  end

  def past_users_count(scope, number_days) do
    true = Scope.is_admin?(scope)

    User.Query.base()
    |> User.Query.last_n_days(number_days)
    |> Repo.aggregate(:count)
  end

  def past_documents_count(scope, number_days) do
    true = Scope.is_admin?(scope)

    Document.Query.base()
    |> Document.Query.last_n_days(number_days)
    |> Repo.aggregate(:count)
  end

  def zero_results(n_days \\ 7) do
    Query.group_by_last_n_days(n_days)
    |> Query.where_zero_results()
    |> Repo.all()
  end

  def failed_results(n_days \\ 7) do
    Query.group_by_last_n_days(n_days)
    |> Query.where_failed_state()
    |> Repo.all()
  end
end

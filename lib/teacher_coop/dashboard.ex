defmodule TeacherCoop.Dashboard do
  alias TeacherCoop.Repo
  alias TeacherCoop.Library.Document
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Accounts.User

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
end

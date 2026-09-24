defmodule TeacherCoop.Dashboard do
  alias TeacherCoop.Repo
  alias TeacherCoop.Library.Document
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Accounts.User

  alias TeacherCoop.Discovery.Search.Query
  alias TeacherCoop.Discovery.Search

  @doc """
  Returns the number of documents in the database
  """
  @spec documents_count(Scope.t()) :: integer()
  def documents_count(%Scope{} = scope) do
    true = Scope.is_admin?(scope)
    Repo.aggregate(Document, :count)
  end

  @doc """
  Returns the number of documents in the database in the past n days.
  """
  @spec past_documents_count(Scope.t(), integer()) :: integer()
  def past_documents_count(scope, number_days) do
    true = Scope.is_admin?(scope)

    Document.Query.base()
    |> Document.Query.last_n_days(number_days)
    |> Repo.aggregate(:count)
  end

  @doc """
  Returns the number of users in the database.
  """
  @spec users_count(Scope.t()) :: integer()
  def users_count(scope) do
    true = Scope.is_admin?(scope)
    Repo.aggregate(User, :count)
  end

  @doc """
  Returns the number of users in the database in the past n days.
  """
  @spec past_users_count(Scope.t(), integer()) :: integer()
  def past_users_count(scope, number_days) do
    true = Scope.is_admin?(scope)

    User.Query.base()
    |> User.Query.last_n_days(number_days)
    |> Repo.aggregate(:count)
  end

  @doc """
  Returns an array os `Search` that got zero_results in the past n days.
  """
  @spec zero_results(integer()) :: [Search.t()]
  def zero_results(n_days) do
    Query.base()
    |> Query.group_by_last_n_days(n_days)
    |> Query.where_zero_results()
    |> Repo.all()
  end

  @doc """
  Returns an array of `Search` with failed state in the past `n` days.
  """
  @spec failed_results(integer()) :: [Search.t()]
  def failed_results(n_days) do
    Query.base()
    |> Query.group_by_last_n_days(n_days)
    |> Query.where_failed_state()
    |> Repo.all()
  end

  @doc """
  Returns an array of `Search` in the past `n` days.
  """
  @spec searches_count(integer()) :: [Search.t()]
  def searches_count(n_days) do
    Query.base()
    |> Query.group_by_last_n_days(n_days)
    |> Repo.all()
  end

  @doc """
  Returns an array of `Search` group by click_position in the past `n` days.
  """
  @spec click_position(integer()) :: [Search.t()]
  def click_position(n_days) do
    Query.base()
    |> Query.last_n_days(n_days)
    |> Query.where_download_true()
    |> Query.group_by_position()
    |> Repo.all()
  end
end

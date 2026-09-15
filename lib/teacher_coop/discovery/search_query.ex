defmodule TeacherCoop.Discovery.Search.Query do
  import Ecto.Query

  alias TeacherCoop.Discovery.Search

  def base(), do: from(s in Search)

  @doc """
  Create query for `Search` and selects:
    - lexeme (tsvector dictionnary)
    - date (truncate inserted_at by day)
    - frequency: count how many word
    - zero_result_count: count how many time a word has return zero results
  """
  @spec base_with_tsvector(String.t()) :: Ecto.Query.t()
  def base_with_tsvector(language) when language in ~w(french english) do
    from(s in Search,
      cross_join:
        w in fragment("unnest(to_tsvector(?::text::regconfig, ?))", ^language, s.search_terms),
      select: %{
        word: w.lexeme,
        date: fragment("date_trunc('day', ?)", s.inserted_at),
        frequency: count(),
        zero_result_count:
          fragment("SUM(CASE WHEN hits_count = 0 THEN 1 ELSE 0 END) as zero_result_count")
      }
    )
  end

  @doc """
  Returns a query that will fetch searches between `start` and `end_date`.
  """
  @spec where_inserted_between(Ecto.Query.t(), DateTime.t(), DateTime.t()) :: Ecto.Query.t()
  def where_inserted_between(query, %DateTime{} = start, %DateTime{} = end_date) do
    where(query, [s], s.inserted_at >= ^start and s.inserted_at <= ^end_date)
  end

  @doc """
  Group Searches results by lexeme and inserted_at.
  """
  @spec group_by_lexeme_and_inserted_at_date(Ecto.Query.t()) :: Ecto.Query.t()
  def group_by_lexeme_and_inserted_at_date(query) do
    group_by(query, [s, w], [
      w.lexeme,
      fragment("date_trunc('day',?)", s.inserted_at)
    ])
  end

  @doc """
  Returns `Search` that have zero hits count.
  """
  @spec where_zero_results(Ecto.Query.t()) :: Ecto.Query.t()
  def where_zero_results(query) do
    where(query, [s], s.hits_count == 0)
  end

  @doc """
  Apply a where on `WordCount.state` == failed.
  """
  @spec where_failed_state(Ecto.Query.t()) :: Ecto.Query.t()
  def where_failed_state(query) do
    where(query, [s], s.state == "failed")
  end

  @doc """
  Selected truncated date, apply a where on last date and group by date.
  """
  @spec group_by_last_n_days(Ecto.Query.t(), integer()) :: Ecto.Query.t()
  def group_by_last_n_days(query, n) do
    query
    |> select_truncated_date()
    |> last_n_days(n)
    |> group_by_date()
  end

  @doc """
  Apply a where to select the last n days.
  """
  @spec last_n_days(Ecto.Query.t(), integer()) :: Ecto.Query.t()
  def last_n_days(query, n) do
    now = DateTime.utc_now()
    epoch = DateTime.to_unix(now)
    date = DateTime.from_unix!(epoch - n * 24 * 60 * 60)
    where(query, [s], s.inserted_at > ^date)
  end

  @doc """
  Apply a select that truncate dates and count rows.
  """
  @spec select_truncated_date(Ecto.Query.t()) :: Ecto.Query.t()
  def select_truncated_date(query) do
    select(query, [s], %{
      date: fragment("date_trunc('day', ?) as date", s.inserted_at),
      count: fragment("count(?)", s.inserted_at)
    })
  end

  @doc """
  Group by date.
  """
  @spec group_by_date(Ecto.Query.t()) :: Ecto.Query.t()
  def group_by_date(query) do
    group_by(query, [s], [fragment("date")])
  end

  @doc """
  Apply a select on position and count rows with a group by position.
  """
  @spec group_by_position(Ecto.Query.t()) :: Ecto.Query.t()
  def group_by_position(query) do
    select(query, [s], %{
      position: s.success_click_position,
      count: fragment("count(?) as count", s.success_click_position)
    })
    |> group_by([s], s.success_click_position)
  end

  @doc """
  Apply a where on `WordCount.state` == success.
  """
  @spec where_download_true(Ecto.Query.t()) :: Ecto.Query.t()
  def where_download_true(query) do
    where(query, [s], s.state == "success")
  end
end

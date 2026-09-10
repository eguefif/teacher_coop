defmodule TeacherCoop.Discovery.Search.Query do
  import Ecto.Query

  alias TeacherCoop.Discovery.Search

  def base(), do: from(s in Search)

  @spec base_with_tsvector(String.t()) :: Ecto.Query.t()
  def base_with_tsvector(language) when language in ~w(french english) do
    from(s in Search,
      cross_join:
        w in fragment("unnest(to_tsvector(?::text::regconfig, ?))", ^language, s.search_terms),
      select: %{
        word: w.lexeme,
        date: fragment("date_trunc('day', ?)", s.inserted_at),
        count: count()
      }
    )
  end

  @doc """
  Returns a query that will fetch searches between `start` and `end_date`
  """
  @spec where_inserted_between(Ecto.Query.t(), DateTime.t(), DateTime.t()) :: Ecto.Query.t()
  def where_inserted_between(query, %DateTime{} = start, %DateTime{} = end_date) do
    where(query, [s], s.inserted_at >= ^start and s.inserted_at <= ^end_date)
  end

  @spec group_by_lexeme_and_inserted_at_date(Ecto.Query.t()) :: Ecto.Query.t()
  def group_by_lexeme_and_inserted_at_date(query) do
    group_by(query, [s, w], [w.lexeme, fragment("date_trunc('day',?)", s.inserted_at)])
  end

  # TODO: check if that works, there is no field date on Search
  def where_date(query, date) do
    where(query, [s], s.date == ^date)
  end

  def where_zero_results(query) do
    where(query, [s], s.hits_count == 0)
  end

  def where_failed_state(query) do
    where(query, [s], s.state == "failed")
  end

  def group_by_last_n_days(query, n) do
    query
    |> select_truncated_date()
    |> last_n_days(n)
    |> group_by_date()
  end

  def last_n_days(query, n) do
    now = DateTime.utc_now()
    epoch = DateTime.to_unix(now)
    date = DateTime.from_unix!(epoch - n * 24 * 60 * 60)
    where(query, [s], s.inserted_at > ^date)
  end

  def select_truncated_date(query) do
    select(query, [s], %{
      date: fragment("date_trunc('day', ?) as date", s.inserted_at),
      count: fragment("count(?)", s.inserted_at)
    })
  end

  def group_by_date(query) do
    group_by(query, [s], [fragment("date")])
  end

  def group_by_position(query) do
    select(query, [s], %{
      position: s.success_click_position,
      count: fragment("count(?) as count", s.success_click_position)
    })
    |> group_by([s], s.success_click_position)
  end

  def where_download_true(query) do
    where(query, [s], s.state == "success")
  end
end

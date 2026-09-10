defmodule TeacherCoop.Discovery.Search.Query do
  import Ecto.Query

  alias TeacherCoop.Discovery.Search

  def base(), do: from(s in Search)

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

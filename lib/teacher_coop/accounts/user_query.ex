defmodule TeacherCoop.Accounts.User.Query do
  import Ecto.Query

  alias TeacherCoop.Accounts.User

  def base(), do: from(u in User)

  def by_ids(query, ids) do
    where(query, [u], u.id in ^ids)
  end

  def last_n_days(query, n) do
    now = DateTime.utc_now()
    epoch = DateTime.to_unix(now)
    date = DateTime.from_unix!(epoch - n * 24 * 60 * 60)
    where(query, [u], u.inserted_at > ^date)
  end
end

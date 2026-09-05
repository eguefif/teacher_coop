defmodule TeacherCoop.Library.Document.Query do
  import Ecto.Query

  alias TeacherCoop.Library.Document

  def base(), do: from(d in Document)

  def by_ids(query, ids) do
    where(query, [d], d.id in ^ids)
  end

  def with_files(query) do
    preload(query, [:files])
  end

  def with_objectives(query) do
    preload(query, [:objectives])
  end

  def last_n_days(query, n) do
    now = DateTime.utc_now()
    epoch = DateTime.to_unix(now)
    date = DateTime.from_unix!(epoch - n * 24 * 60 * 60)
    where(query, [d], d.inserted_at > ^date)
  end
end

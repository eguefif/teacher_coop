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
end

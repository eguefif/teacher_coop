defmodule TeacherCoop.Dashboard.WordCount.Query do
  import Ecto.Query

  alias TeacherCoop.Dashboard.WordCount

  def base(), do: from(w in WordCount)

  def group_by_words(query) do
    select(query, [w], [w.word, sum(w.count)])
    |> group_by([w], [w.word])
  end

  def on_conflict() do
    from(w in WordCount,
      update: [set: [count: fragment("? + EXCLUDED.count", w.count)]]
    )
  end

  @doc """
  Apply a where statement to a query that check count field for word
  """
  @spec word_contain(Ecto.Query.t(), String.t(), String.t()) :: Ecto.Query.t()
  def word_contain(query, word, language \\ "french") do
    where(
      query,
      [w],
      fragment(
        "to_tsvector(?::text::regconfig, ?) @@ plainto_tsquery(?::text::regconfig, ?)",
        ^language,
        w.word,
        ^language,
        ^word
      )
    )
  end

  # TODO: the query word whould be lexeminized too to match the word.

  def select_sum_count(query) do
    select(query, [w], sum(w.count))
  end
end

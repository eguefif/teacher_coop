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
      update: [
        set: [
          frequency: fragment("? + EXCLUDED.frequency", w.frequency),
          zero_result_count: fragment("? + EXCLUDED.zero_result_count", w.zero_result_count)
        ]
      ]
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

  @spec top_search_words(Ecto.Query.t(), integer()) :: Ecto.Query.t()
  def top_search_words(query, l \\ 15) do
    query
    |> order_by([w], desc: w.frequency)
    |> limit(^l)
  end

  @spec where_no_results(Ecto.Query.t()) :: Ecto.Query.t()
  def where_no_results(query) do
    query
    |> where([w], w.zero_result_count == 0)
  end
end

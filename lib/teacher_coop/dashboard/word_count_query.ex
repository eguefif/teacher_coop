defmodule TeacherCoop.Dashboard.WordCount.Query do
  import Ecto.Query

  alias TeacherCoop.Dashboard.WordCount

  @doc """
  Create a basic query for `WordCount` table.
  """
  @spec base() :: Ecto.Query.t()
  def base(), do: from(w in WordCount)

  @doc """
  Select word and sum(count) and group by words.
  """
  @spec group_by_words(Ecto.Query.t()) :: Ecto.Query.t()
  def group_by_words(query) do
    select(query, [w], [w.word, sum(w.frequency)])
    |> group_by([w], [w.word])
  end

  @doc """
  Apply a where statement to a query that check count field for word.
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

  @doc """
  Select word frequencies sum.
  """
  @spec select_sum_count(Ecto.Query.t()) :: Ecto.Query.t()
  def select_sum_count(query) do
    # TODO: the query word whould be lexeminized too to match the word.
    select(query, [w], sum(w.frequency))
  end

  @spec top_search_words(Ecto.Query.t(), integer()) :: Ecto.Query.t()
  def top_search_words(query, l) do
    query
    |> order_by([w], desc: w.frequency)
    |> limit(^l)
  end

  @doc """
  Apply a where on words with no results.
  """
  @spec where_no_results(Ecto.Query.t()) :: Ecto.Query.t()
  def where_no_results(query) do
    query
    |> where([w], w.zero_result_count == 0)
  end
end

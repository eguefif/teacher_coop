defmodule TeacherCoop.Dashboard.WordStats do
  @moduledoc """
  Subcontext to Dashboard, this module provides context functions
  to manipulates word related tables.
  """
  import Ecto.Query
  alias TeacherCoop.Repo
  alias TeacherCoop.Dashboard.WordCount
  alias TeacherCoop.Discovery.Search

  @type pg_dictionnary_language() :: String.t()

  @doc """
  Populate the word_counts table with search terms and their count.
  Count is how many occurences of the word we have in searches.
  language: 'french', 'english' to use in Postgres
  """
  @spec populate_words_count(pg_dictionnary_language(), DateTime.t(), DateTime.t()) ::
          :error | :ok
  def populate_words_count(language, %DateTime{} = start, %DateTime{} = end_date) do
    search_query =
      Search.Query.base_with_tsvector(language)
      |> Search.Query.where_inserted_between(start, end_date)
      |> Search.Query.group_by_lexeme_and_inserted_at_date()

    {result, _} =
      Repo.insert_all(WordCount, search_query,
        conflict_target: [:word, :date],
        on_conflict:
          from(w in WordCount,
            update: [
              set: [
                frequency: fragment("? + EXCLUDED.frequency", w.frequency),
                zero_result_count: fragment("? + EXCLUDED.zero_result_count", w.zero_result_count)
              ]
            ]
          )
      )

    if is_nil(result), do: :error, else: :ok
  end

  @doc """
  Returns a list of the most popular words.
  """
  @spec top_search_terms(integer()) :: [Ecto.Schema.t() | term()]
  def top_search_terms(limit \\ 15) do
    WordCount.Query.base()
    |> WordCount.Query.top_search_words(limit)
    |> Repo.all()
  end

  @doc """
  Returns a list of the most popular words that get no results from the search.
  """
  @spec top_search_terms_with_no_result(integer()) :: [Ecto.Schema.t() | term()]
  def top_search_terms_with_no_result(limit \\ 15) do
    WordCount.Query.base()
    |> WordCount.Query.top_search_words(limit)
    |> WordCount.Query.where_no_results()
    |> Repo.all()
  end

  @doc """
  Returns all the WordCount rows.
  """
  @spec list_all() :: [Ecto.Schema.t() | term()]
  def list_all() do
    Repo.all(WordCount)
  end

  @doc """
  Returns total counts for each word.
  """
  @spec counts_by_word() :: map()
  def counts_by_word do
    WordCount.Query.base()
    |> WordCount.Query.group_by_words()
    |> Repo.all()
  end

  @doc """
  Returns total counts for all the word starting with
  """
  @spec total_for(String.t()) :: integer()
  def total_for(word) do
    result =
      WordCount.Query.base()
      |> WordCount.Query.word_contain(word)
      |> WordCount.Query.select_sum_count()
      |> Repo.one()

    if result, do: result, else: 0
  end

  @doc """
  Return the last inserted row based on the table ordered by date.
  """
  @spec last_entry_date() :: Date.t() | nil
  def last_entry_date() do
    WordCount.Query.base()
    |> select([w], w.date)
    |> order_by(desc: :date)
    |> Repo.one()
  end
end

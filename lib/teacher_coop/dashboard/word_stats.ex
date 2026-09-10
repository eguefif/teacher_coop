defmodule TeacherCoop.Dashboard.WordStats do
  @moduledoc """
  Subcontext to Dashboard, this module provides context functions
  to manipulates word related tables.
  """
  alias TeacherCoop.Repo
  alias TeacherCoop.Dashboard.WordCount
  alias TeacherCoop.Discovery.Search

  @doc """
  Populate the word_counts table.
  """
  @spec populate_words_count(String.t(), DateTime.t(), DateTime.t()) ::
          {non_neg_integer(), nil | [term()]}
  def populate_words_count(language, %DateTime{} = start, %DateTime{} = end_date) do
    search_query =
      Search.Query.base_with_tsvector(language)
      |> Search.Query.where_inserted_between(start, end_date)
      |> Search.Query.group_by_lexeme_and_inserted_at_date()

    Repo.insert_all(WordCount, search_query,
      conflict_target: [:word, :date],
      on_conflict: WordCount.Query.on_conflict()
    )
  end

  def list_all() do
    Repo.all(WordCount)
  end

  @doc """
  Returns total counts for each word
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
end

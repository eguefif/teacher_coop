defmodule TeacherCoop.Dashboard.WordStatsTest do
  use TeacherCoop.DataCase, async: true

  alias TeacherCoop.Dashboard.WordCount
  alias TeacherCoop.Dashboard.WordStats
  alias TeacherCoop.DiscoveryFixtures

  # `populate_words_count/3` lexemises the `search_terms` of every search whose
  # `inserted_at` falls inside the window, then aggregates a count per
  # (lexeme, day) into `word_counts`.

  defp days_ago(n) do
    DateTime.utc_now()
    |> DateTime.add(-n * 24 * 60 * 60, :second)
    |> DateTime.truncate(:second)
  end

  defp search_at(days, terms, hits_count) do
    DiscoveryFixtures.search_fixture(nil, %{
      search_terms: terms,
      hits_count: hits_count,
      inserted_at: days_ago(days)
    })
  end

  defp seed_history do
    # In window (last 5 days), a few terms repeated across several days.
    search_at(1, "les fractions equivalentes", 12)
    search_at(1, "additionner les fractions", 8)
    search_at(1, "la geometrie du triangle", 0)
    search_at(2, "reduire une fraction", 5)
    search_at(2, "table de multiplication", 20)
    search_at(3, "geometrie dans l espace", 3)

    # Out of window: must not contribute to any count.
    search_at(20, "revision avant les vacances", 42)
  end

  describe "populate_words_count/3" do
    setup do
      seed_history()
      :ok
    end

    test "aggregates a count per lexeme over the window" do
      WordStats.populate_words_count("french", days_ago(5), days_ago(0))

      counts =
        WordStats.counts_by_word()
        |> Map.new(fn [word, count] -> {word, count} end)

      refute counts == %{}, "expected word_counts to be populated"

      # "fractions" / "fraction" appears in 3 in-window searches.
      assert WordStats.total_for("fraction") == 3
      # "geometrie" appears in 2 in-window searches.
      assert WordStats.total_for("geometri") == 2
    end

    test "buckets counts by day" do
      WordStats.populate_words_count("french", days_ago(5), days_ago(0))

      fraction_rows =
        WordCount
        |> Repo.all()
        |> Enum.filter(&String.starts_with?(&1.word, "fraction"))

      # 2 occurrences on day -1, 1 occurrence on day -2 => two dated rows.
      assert length(Enum.uniq_by(fraction_rows, & &1.date)) == 2
    end

    test "ignores searches outside the window" do
      WordStats.populate_words_count("french", days_ago(5), days_ago(0))

      # "vacances" only appears in the out-of-window search.
      assert WordStats.total_for("vacance") == 0
      assert WordStats.total_for("revision") == 0
    end

    test "is idempotent per run and sums on re-run via upsert" do
      WordStats.populate_words_count("french", days_ago(5), days_ago(0))
      first = WordStats.total_for("fraction")

      WordStats.populate_words_count("french", days_ago(5), days_ago(0))
      second = WordStats.total_for("fraction")

      assert second == first * 2
    end
  end

  describe "list_all\1" do
    setup do
      seed_history()
      :ok
    end

    test "returns all 12 lexemes" do
      WordStats.populate_words_count("french", days_ago(5), days_ago(0))

      word_counts = WordStats.list_all()

      assert length(word_counts) == 12
    end
  end
end

defmodule TeacherCoop.Dashboard.Workers.PopulateWordsTableWorker do
  @moduledoc """
  Populates word_counts and word_zero_result_counts tables.
  """
  use Oban.Worker,
    queue: :stats,
    unique: true

  alias TeacherCoop.Dashboard.WordStats

  @doc """
  Populate the word count database. It automatically get the last entry
  and populate from the `Search` table using the last date.
  """
  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: Oban.Worker.result()
  def perform(%Oban.Job{}) do
    day =
      case WordStats.last_entry_date() do
        nil -> Date.utc_today()
        date -> date
      end

    start_day = DateTime.new!(day, ~T[00:00:00], "Etc/UTC")
    end_day = DateTime.new!(Date.add(day, 1), ~T[00:00:00], "Etc/UTC")
    WordStats.populate_words_count("french", start_day, end_day)
  end
end

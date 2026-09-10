defmodule TeacherCoop.Dashboard.Workers.PopulateWordsTableWorker do
  @moduledoc """
  Populates word_counts and word_zero_result_counts tables.
  """
  use Oban.Worker,
    queue: :stats,
    unique: true

  alias TeacherCoop.Dashboard.WordStats

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    # TODO: actually, we should retrieve the date of the last word input
    # and add as many populate words count as we require. The job might failed
    # we need a way to catch up
    day = Date.utc_today()
    start_day = DateTime.new!(day, ~T[00:00:00], "Etc/UTC")
    end_day = DateTime.new!(Date.add(day, 1), ~T[00:00:00], "Etc/UTC")
    WordStats.populate_words_count("french", start_day, end_day)
  end
end

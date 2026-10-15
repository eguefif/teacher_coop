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
    with {:ok, start_day} <- get_start_day() do
      end_day = DateTime.utc_now()

      WordStats.populate_words_count("french", start_day, end_day)
    else
      {:error, :no_start_date} -> {:cancel, :no_start_date}
    end
  end

  @spec get_start_day() :: {:ok, DateTime.t()} | {:error, :no_start_date}
  defp get_start_day() do
    case WordStats.last_entry_date() do
      nil ->
        get_first_search_entry()

      date ->
        {:ok, DateTime.new!(date, ~T[00:00:00], "Etc/UTC")}
    end
  end

  @spec get_first_search_entry() :: {:ok, DateTime.t()} | {:error, :no_start_date}
  defp get_first_search_entry() do
    case TeacherCoop.Discovery.get_first_search_date() do
      nil ->
        {:error, :no_start_date}

      search_date ->
        {:ok, DateTime.new!(DateTime.to_date(search_date.date), ~T[00:00:00], "Etc/UTC")}
    end
  end
end

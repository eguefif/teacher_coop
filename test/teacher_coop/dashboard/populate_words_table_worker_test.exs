defmodule TeacherCoop.Dashboard.PopulateWordsTableWorkerTest do
  use TeacherCoop.DataCase

  import TeacherCoop.DiscoveryFixtures, only: [search_fixture: 2]
  import TeacherCoop.DashboardFixtures, only: [word_count_fixture: 1]
  alias TeacherCoop.Dashboard.Workers.PopulateWordsTableWorker

  test "perform_job/1 no entry yet in WordsCount" do
    search_fixture(nil, %{})
    assert :ok = perform_job(PopulateWordsTableWorker, %{})
  end

  test "perform_job/1 no entry yet in WordsCount backfills from the first search" do
    first_day = DateTime.add(DateTime.utc_now(), -10, :day) |> DateTime.truncate(:second)
    search_fixture(nil, %{search_terms: "fractions", inserted_at: first_day})
    search_fixture(nil, %{search_terms: "geometrie", inserted_at: DateTime.utc_now()})

    assert :ok = perform_job(PopulateWordsTableWorker, %{})
    assert TeacherCoop.Dashboard.WordStats.last_entry_date() == Date.utc_today()

    assert TeacherCoop.Repo.exists?(
             from(w in TeacherCoop.Dashboard.WordCount,
               where: w.date == ^DateTime.to_date(first_day)
             )
           )
  end

  test "perform_job/1 no entry yet in WordsCount and not searches" do
    assert {:cancel, :no_start_date} = perform_job(PopulateWordsTableWorker, %{})
  end

  test "perform_job/1 already one entry yet in WordsCount" do
    word_count_fixture(%{date: Date.add(Date.utc_today(), -1)})
    search_fixture(nil, %{inserted_at: DateTime.utc_now()})
    assert :ok = perform_job(PopulateWordsTableWorker, %{})
  end
end

defmodule TeacherCoop.Dashboard.PopulateWordsTableWorkerTest do
  use ExUnit.Case, async: true
  use TeacherCoop.DataCase

  import TeacherCoop.DiscoveryFixtures, only: [search_fixture: 2]
  import TeacherCoop.DashboardFixtures, only: [word_count_fixture: 1]
  alias TeacherCoop.Dashboard.Workers.PopulateWordsTableWorker

  test "perform_job/1 no entry yet in WordsCount" do
    search_fixture(nil, %{})
    assert :ok = perform_job(PopulateWordsTableWorker, %{})
  end

  test "perform_job/1 already one entry yet in WordsCount" do
    word_count_fixture(%{date: Date.add(Date.utc_today(), -1)})
    search_fixture(nil, %{inserted_at: DateTime.utc_now()})
    assert :ok = perform_job(PopulateWordsTableWorker, %{})
  end
end

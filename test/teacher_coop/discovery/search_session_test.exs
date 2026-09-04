defmodule TeacherCoop.Discovery.SearchSessionTest do
  use ExUnit.Case, async: true

  alias TeacherCoop.Discovery.SearchSession

  describe "get_hits/1" do
    test "returns the hits from the session results" do
      session = %SearchSession{results: %{hits: [%{"id" => 1}, %{"id" => 2}]}}

      assert SearchSession.get_hits(session) == [%{"id" => 1}, %{"id" => 2}]
    end

    test "returns an empty list when there are no hits" do
      session = %SearchSession{results: %{hits: []}}

      assert SearchSession.get_hits(session) == []
    end
  end

  describe "add_search_terms/2" do
    test "records the search terms on the session" do
      session = %SearchSession{}

      assert %SearchSession{search_terms: "fractions"} =
               SearchSession.add_search_terms(session, "fractions")
    end

    test "overwrites previously recorded search terms" do
      session = %SearchSession{search_terms: "fractions"}

      assert %SearchSession{search_terms: "algebra"} =
               SearchSession.add_search_terms(session, "algebra")
    end

    test "leaves the other fields untouched" do
      session = %SearchSession{session_id: "abc", db_results: [:a]}

      updated = SearchSession.add_search_terms(session, "fractions")

      assert updated.session_id == "abc"
      assert updated.db_results == [:a]
    end
  end

  describe "add_search_results/3" do
    test "records the results and db_results on the session" do
      session = %SearchSession{}
      results = %{hits: [%{"id" => 1}]}
      db_results = [%{id: 1}]

      updated = SearchSession.add_search_results(session, results, db_results)

      assert updated.results == results
      assert updated.db_results == db_results
    end

    test "overwrites previously recorded results" do
      session = %SearchSession{results: %{hits: [:old]}, db_results: [:old]}

      updated = SearchSession.add_search_results(session, %{hits: [:new]}, [:new])

      assert updated.results == %{hits: [:new]}
      assert updated.db_results == [:new]
    end

    test "leaves the other fields untouched" do
      session = %SearchSession{session_id: "abc", search_terms: "fractions"}

      updated = SearchSession.add_search_results(session, %{hits: []}, [])

      assert updated.session_id == "abc"
      assert updated.search_terms == "fractions"
    end
  end

  describe "add_search_record/2" do
    test "records the search record on the session" do
      session = %SearchSession{}
      record = %{id: 42}

      assert %SearchSession{search_record: ^record} =
               SearchSession.add_search_record(session, record)
    end

    test "overwrites a previously recorded search record" do
      session = %SearchSession{search_record: %{id: 1}}

      assert %SearchSession{search_record: %{id: 2}} =
               SearchSession.add_search_record(session, %{id: 2})
    end

    test "leaves the other fields untouched" do
      session = %SearchSession{session_id: "abc", search_terms: "fractions"}

      updated = SearchSession.add_search_record(session, %{id: 42})

      assert updated.session_id == "abc"
      assert updated.search_terms == "fractions"
    end
  end
end

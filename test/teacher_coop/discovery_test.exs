defmodule TeacherCoop.DiscoveryTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Discovery
  alias TeacherCoop.Discovery.{Search, SearchSession}
  alias TeacherCoop.SearchRepo.SearchDocuments

  describe "discovery" do
    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeacherCoop.DiscoveryFixtures

    test "list_searches/1 returns only the scope user's searches" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      search = search_fixture(scope)
      _other = search_fixture(other_scope)

      assert Discovery.list_searches(scope) == [search]
    end

    test "get_search!/2 returns the scope user's search" do
      scope = user_scope_fixture()
      search = search_fixture(scope)

      assert Discovery.get_search!(scope, search.id) == search
    end

    test "get_search!/2 raises for another user's search" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      search = search_fixture(other_scope)

      assert_raise Ecto.NoResultsError, fn -> Discovery.get_search!(scope, search.id) end
    end

    test "create_search_session/1 builds a session for the scope" do
      scope = user_scope_fixture()

      session = Discovery.create_search_session(scope)

      assert %SearchSession{} = session
      assert session.scope == scope
      assert session.document_index == "documents"
      assert %DateTime{} = session.created_at
      assert is_binary(session.session_id)
      assert session.search_record == nil
      assert session.db_results == []
    end

    test "update_current_search/1 returns the session unchanged when there is no current search" do
      scope = user_scope_fixture()
      session = search_session_fixture(scope)

      assert Discovery.update_current_search(session) == session
    end

    test "update_current_search/1 clears the current search record when a new search starts" do
      scope = user_scope_fixture()
      search = search_fixture(scope)
      session = search_session_fixture(scope, search_record: search)

      assert %SearchSession{search_record: nil} = Discovery.update_current_search(session)
    end

    test "save_successful_search/2 returns the updated search record" do
      scope = user_scope_fixture()
      search = search_fixture(scope)
      session = search_session_fixture(scope, search_record: search)

      assert {:ok, %Search{} = updated} = Discovery.save_successful_search(session, 3)
      assert updated.id == search.id
    end

    test "delete_search/2 deletes the scope user's search" do
      scope = user_scope_fixture()
      search = search_fixture(scope)

      assert {:ok, %Search{}} = Discovery.delete_search(scope, search)
      assert Discovery.list_searches(scope) == []
    end

    test "delete_search/2 refuses to delete another user's search" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      search = search_fixture(other_scope)

      assert_raise MatchError, fn -> Discovery.delete_search(scope, search) end
    end

    test "change_search/3 returns a search changeset" do
      scope = user_scope_fixture()
      search = search_fixture(scope)

      assert %Ecto.Changeset{} = Discovery.change_search(scope, search)
    end
  end

  describe "handle_search/2" do
    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeacherCoop.DiscoveryFixtures
    import TeacherCoop.LibraryFixtures

    # `document_fixture/2` only enqueues the indexing job; run it so the document
    # is actually searchable in Meilisearch, and drop it again afterwards so the
    # (non-sandboxed) test index does not leak between tests.
    defp index_document!(scope, attrs) do
      document = document_fixture(scope, attrs)
      assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :document_ingestion)
      on_exit(fn -> SearchDocuments.delete_document(document.id) end)
      document
    end

    test "records the search terms on the returned session" do
      scope = user_scope_fixture()
      session = search_session_fixture(scope)

      assert %SearchSession{search_terms: "fractions"} =
               Discovery.handle_search(session, "fractions")
    end

    test "returns an empty result set when nothing matches" do
      scope = user_scope_fixture()
      session = search_session_fixture(scope)

      session = Discovery.handle_search(session, "zzz-no-such-document-zzz")

      assert session.results.hits == []
      assert session.db_results == []
    end

    test "populates results and db_results with the matching document" do
      scope = user_scope_fixture()
      term = "photosynthesexyz"
      document = index_document!(scope, %{title: term, description: "a lesson about #{term}"})

      session =
        scope
        |> search_session_fixture()
        |> Discovery.handle_search(term)

      assert [%{"id" => hit_id}] = session.results.hits
      assert hit_id == document.id
      assert [%TeacherCoop.Library.Document{id: ^hit_id}] = session.db_results
    end

    test "orders db_results to mirror the search hit ranking" do
      scope = user_scope_fixture()
      term = "algebrxyz"
      # Title match ranks ahead of a description-only match.
      title_match = index_document!(scope, %{title: term, description: "intro"})
      body_match = index_document!(scope, %{title: "misc", description: "all about #{term}"})

      session =
        scope
        |> search_session_fixture()
        |> Discovery.handle_search(term)

      hit_ids = Enum.map(session.results.hits, & &1["id"])
      assert Enum.sort(hit_ids) == Enum.sort([title_match.id, body_match.id])
      assert Enum.map(session.db_results, & &1.id) == hit_ids
    end

    # Characterisation test: `create_search_record/1` never passes `:search_terms`,
    # which `Search.changeset/3` marks as required, so the record is never
    # persisted and the session carries the failed changeset instead. Update this
    # test if the insert is fixed.
    test "does not persist a Search record and keeps the failed changeset on the session" do
      scope = user_scope_fixture()
      session = search_session_fixture(scope)

      session = Discovery.handle_search(session, "fractions")

      assert {:error, %Ecto.Changeset{} = changeset} = session.search_record
      assert %{search_terms: ["can't be blank"]} = errors_on(changeset)
      assert Discovery.list_searches(scope) == []
    end
  end

  describe "search changeset" do
    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]

    test "Search.changeset/3 with nil scope casts the full range of fields" do
      attrs = %{
        search_terms: "fractions",
        hits_count: 12,
        success: true,
        success_click_position: 2,
        dwell_time: 4500,
        document_index: "documents"
      }

      changeset = Search.changeset(%Search{}, attrs, nil)

      assert changeset.valid?

      search = Ecto.Changeset.apply_changes(changeset)
      assert search.search_terms == "fractions"
      assert search.hits_count == 12
      assert search.success == true
      assert search.success_click_position == 2
      assert search.dwell_time == 4500
      assert search.document_index == "documents"
    end

    test "Search.changeset/3 with nil scope requires search_terms" do
      changeset = Search.changeset(%Search{}, %{hits_count: 3}, nil)

      refute changeset.valid?
      assert %{search_terms: ["can't be blank"]} = errors_on(changeset)
    end

    test "Search.changeset/3 with a scope only permits search_terms and stamps user_id" do
      scope = user_scope_fixture()
      attrs = %{search_terms: "fractions", hits_count: 99, success: true}

      changeset = Search.changeset(%Search{}, attrs, scope)

      assert changeset.valid?

      search = Ecto.Changeset.apply_changes(changeset)
      assert search.search_terms == "fractions"
      assert search.user_id == scope.user.id
      refute search.hits_count
      refute search.success
    end
  end
end

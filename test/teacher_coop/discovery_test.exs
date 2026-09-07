defmodule TeacherCoop.DiscoveryTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Discovery
  # alias TeacherCoop.Discovery.{Search, SearchSession}
  # alias TeacherCoop.SearchRepo.SearchDocuments

  describe "discovery" do
    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeacherCoop.DiscoveryFixtures

    test "get_search_session" do
      scope = user_scope_fixture()
      session = search_session_fixture(scope)
      retrieved_session = Discovery.get_search_session!(session.id)
      assert retrieved_session.user == scope.user
      assert retrieved_session.state == "searching"
    end

    test "create_session no scope" do
      session = search_session_fixture(nil)
      retrieved_session = Discovery.get_search_session!(session.id)
      assert retrieved_session.user == nil
      assert retrieved_session.state == "searching"
    end
  end
end

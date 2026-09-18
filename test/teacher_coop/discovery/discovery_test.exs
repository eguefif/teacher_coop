defmodule TeacherCoop.DiscoveryTest do
  use ExUnit.Case, async: true
  use TeacherCoop.DataCase

  alias TeacherCoop.DiscoveryFixtures

  test "handle_search/4 default value" do
    assert {:error, changeset, [], []} = TeacherCoop.Discovery.handle_search()
    assert changeset.valid? == false
  end

  test "change\2" do
    assert changeset = TeacherCoop.Discovery.change_search()
    assert changeset.valid? == false
  end

  test "update_search\3 default value" do
    search = DiscoveryFixtures.search_fixture()
    assert {:ok, search_ret} = TeacherCoop.Discovery.update_search(search)
    assert search_ret.id == search.id
  end
end

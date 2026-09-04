defmodule TeacherCoop.ConfigurationTest do
  use TeacherCoop.DataCase
  alias TeacherCoop.Discovery.Configuration

  describe "configuration" do
    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 1]
    import TeacherCoop.ConfigurationFixtures

    test "get_index/2 return one index" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.get_index!(index.id, scope) == index
    end
  end
end

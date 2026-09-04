defmodule TeacherCoop.ConfigurationTest do
  use TeacherCoop.DataCase
  alias TeacherCoop.Discovery.Configuration
  alias TeacherCoop.Discovery.Configuration.Index
  alias TeacherCoop.Discovery.Configuration.Workers.UpdateConfig

  describe "configuration" do
    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 1]
    import TeacherCoop.ConfigurationFixtures

    test "get_index/2 return one index" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.get_index!(index.id, scope) == index
    end

    test "get_index/2 return one index using :bypass_auth" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.get_index!(index.id, :bypass_auth) == index
    end

    test "get_index_by_name/2 return one index" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.get_index_by_name!(index.name, :bypass_auth) == index
    end

    test "set_index_to_error_indexing/1" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope)

      Configuration.set_index_to_error_indexing(index)
      index = Configuration.get_index!(index.id, scope)
      assert index.state == "error_indexing"
    end

    test "set_index_to_indexing/1" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope)

      Configuration.set_index_to_indexing(index)
      index = Configuration.get_index!(index.id, scope)
      assert index.state == "indexing"
    end

    test "set_index_to_indexed/1" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope)

      Configuration.set_index_to_indexed(index)
      index = Configuration.get_index!(index.id, scope)
      assert index.state == "indexed"
    end

    test "change_index/1 returns a document changeset" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope)
      assert %Ecto.Changeset{} = Configuration.change_index(scope, index)
    end

    test "change_index/1 returns error with missing name" do
      scope = user_scope_fixture(:admin)

      attrs = %{
        state: "indexing"
      }

      changeset = Index.changeset(%Index{}, attrs, scope)
      assert changeset.valid? == false
      assert List.keymember?(changeset.errors, :name, 0)
    end

    test "list_index/1" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.list_index(scope) == [index]
    end

    test "delete_index/2" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      Configuration.delete_index(index, scope)
      assert Configuration.list_index(scope) == []
    end

    test "create_index/2 with engine_configuration_id to schedule oban" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      attrs = %{
        name: "An index",
        engine_configuration_id: config.id
      }

      {:ok, index} = Configuration.create_index(attrs, scope)

      assert_enqueued worker: UpdateConfig,
                      args: %{
                        "indexname" => index.name,
                        "config_id" => config.id
                      }
    end

    test "update_index/2 update name" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      attrs = %{
        name: "An index",
        engine_configuration_id: config.id
      }

      {:ok, index} = Configuration.create_index(attrs, scope)

      {:ok, index} = Configuration.update_index(index, %{name: "New name"}, scope)
      assert index.name == "New name"
    end

    test "update_index/2 with engine_configuration_id to schedule oban" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      attrs = %{
        name: "An index",
        engine_configuration_id: config.id
      }

      {:ok, index} = Configuration.create_index(attrs, scope)

      {:ok, index} = Configuration.update_index(index, %{name: "New name"}, scope)

      assert_enqueued worker: UpdateConfig,
                      args: %{
                        "indexname" => index.name,
                        "config_id" => config.id
                      }
    end
  end
end

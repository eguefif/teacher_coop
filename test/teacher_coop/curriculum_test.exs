defmodule TeacherCoop.CurriculumTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Curriculum

  describe "curriculum_items" do
    alias TeacherCoop.Curriculum.CurriculumItem

    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeacherCoop.CurriculumFixtures

    @invalid_attrs %{}

    test "list_curriculum_items/1 returns all scoped curriculum_items" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      curriculum_item = curriculum_item_fixture(scope)
      other_curriculum_item = curriculum_item_fixture(other_scope)
      assert Curriculum.list_curriculum_items(scope) == [curriculum_item]
      assert Curriculum.list_curriculum_items(other_scope) == [other_curriculum_item]
    end

    test "get_curriculum_item!/2 returns the curriculum_item with given id" do
      scope = user_scope_fixture()
      curriculum_item = curriculum_item_fixture(scope)
      other_scope = user_scope_fixture()
      assert Curriculum.get_curriculum_item!(scope, curriculum_item.id) == curriculum_item
      assert_raise Ecto.NoResultsError, fn -> Curriculum.get_curriculum_item!(other_scope, curriculum_item.id) end
    end

    test "create_curriculum_item/2 with valid data creates a curriculum_item" do
      valid_attrs = %{}
      scope = user_scope_fixture()

      assert {:ok, %CurriculumItem{} = curriculum_item} = Curriculum.create_curriculum_item(scope, valid_attrs)
      assert curriculum_item.user_id == scope.user.id
    end

    test "create_curriculum_item/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Curriculum.create_curriculum_item(scope, @invalid_attrs)
    end

    test "update_curriculum_item/3 with valid data updates the curriculum_item" do
      scope = user_scope_fixture()
      curriculum_item = curriculum_item_fixture(scope)
      update_attrs = %{}

      assert {:ok, %CurriculumItem{} = curriculum_item} = Curriculum.update_curriculum_item(scope, curriculum_item, update_attrs)
    end

    test "update_curriculum_item/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      curriculum_item = curriculum_item_fixture(scope)

      assert_raise MatchError, fn ->
        Curriculum.update_curriculum_item(other_scope, curriculum_item, %{})
      end
    end

    test "update_curriculum_item/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      curriculum_item = curriculum_item_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Curriculum.update_curriculum_item(scope, curriculum_item, @invalid_attrs)
      assert curriculum_item == Curriculum.get_curriculum_item!(scope, curriculum_item.id)
    end

    test "delete_curriculum_item/2 deletes the curriculum_item" do
      scope = user_scope_fixture()
      curriculum_item = curriculum_item_fixture(scope)
      assert {:ok, %CurriculumItem{}} = Curriculum.delete_curriculum_item(scope, curriculum_item)
      assert_raise Ecto.NoResultsError, fn -> Curriculum.get_curriculum_item!(scope, curriculum_item.id) end
    end

    test "delete_curriculum_item/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      curriculum_item = curriculum_item_fixture(scope)
      assert_raise MatchError, fn -> Curriculum.delete_curriculum_item(other_scope, curriculum_item) end
    end

    test "change_curriculum_item/2 returns a curriculum_item changeset" do
      scope = user_scope_fixture()
      curriculum_item = curriculum_item_fixture(scope)
      assert %Ecto.Changeset{} = Curriculum.change_curriculum_item(scope, curriculum_item)
    end
  end
end

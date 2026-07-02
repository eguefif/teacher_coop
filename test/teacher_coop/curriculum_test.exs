defmodule TeacherCoop.CurriculumTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Curriculum

  describe "objectives" do
    alias TeacherCoop.Curriculum.Objective

    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeacherCoop.CurriculumFixtures

    @invalid_attrs %{year: nil, subject: nil, grade: nil, goal: nil}

    test "list_objectives/1 returns all scoped objectives" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      objective = objective_fixture(scope)
      other_objective = objective_fixture(other_scope)
      assert Curriculum.list_objectives(scope) == [objective]
      assert Curriculum.list_objectives(other_scope) == [other_objective]
    end

    test "get_objective!/2 returns the objective with given id" do
      scope = user_scope_fixture()
      objective = objective_fixture(scope)
      other_scope = user_scope_fixture()
      assert Curriculum.get_objective!(scope, objective.id) == objective
      assert_raise Ecto.NoResultsError, fn -> Curriculum.get_objective!(other_scope, objective.id) end
    end

    test "create_objective/2 with valid data creates a objective" do
      valid_attrs = %{year: 42, subject: "some subject", grade: "some grade", goal: "some goal"}
      scope = user_scope_fixture()

      assert {:ok, %Objective{} = objective} = Curriculum.create_objective(scope, valid_attrs)
      assert objective.year == 42
      assert objective.subject == "some subject"
      assert objective.grade == "some grade"
      assert objective.goal == "some goal"
      assert objective.user_id == scope.user.id
    end

    test "create_objective/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Curriculum.create_objective(scope, @invalid_attrs)
    end

    test "update_objective/3 with valid data updates the objective" do
      scope = user_scope_fixture()
      objective = objective_fixture(scope)
      update_attrs = %{year: 43, subject: "some updated subject", grade: "some updated grade", goal: "some updated goal"}

      assert {:ok, %Objective{} = objective} = Curriculum.update_objective(scope, objective, update_attrs)
      assert objective.year == 43
      assert objective.subject == "some updated subject"
      assert objective.grade == "some updated grade"
      assert objective.goal == "some updated goal"
    end

    test "update_objective/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      objective = objective_fixture(scope)

      assert_raise MatchError, fn ->
        Curriculum.update_objective(other_scope, objective, %{})
      end
    end

    test "update_objective/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      objective = objective_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Curriculum.update_objective(scope, objective, @invalid_attrs)
      assert objective == Curriculum.get_objective!(scope, objective.id)
    end

    test "delete_objective/2 deletes the objective" do
      scope = user_scope_fixture()
      objective = objective_fixture(scope)
      assert {:ok, %Objective{}} = Curriculum.delete_objective(scope, objective)
      assert_raise Ecto.NoResultsError, fn -> Curriculum.get_objective!(scope, objective.id) end
    end

    test "delete_objective/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      objective = objective_fixture(scope)
      assert_raise MatchError, fn -> Curriculum.delete_objective(other_scope, objective) end
    end

    test "change_objective/2 returns a objective changeset" do
      scope = user_scope_fixture()
      objective = objective_fixture(scope)
      assert %Ecto.Changeset{} = Curriculum.change_objective(scope, objective)
    end
  end
end

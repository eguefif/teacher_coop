defmodule TeacherCoop.CurriculumTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Curriculum

  describe "objectives" do
    alias TeacherCoop.Curriculum.Objective

    import TeacherCoop.CurriculumFixtures

    @invalid_attrs %{year: nil, subject: nil, grade: nil, goal: nil}

    test "get_objective!/2 returns the objective with given id" do
      objective = objective_fixture()
      assert Curriculum.get_objective!(objective.id) == objective
    end

    test "create_objective/2 with valid data creates a objective" do
      valid_attrs = %{year: 42, subject: "some subject", grade: "some grade", goal: "some goal"}
      assert {:ok, %Objective{} = objective} = Curriculum.create_objective(valid_attrs)
      assert objective.year == 42
      assert objective.subject == "some subject"
      assert objective.grade == "some grade"
      assert objective.goal == "some goal"
    end

    test "create_objective/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Curriculum.create_objective(@invalid_attrs)
    end

    test "update_objective/3 with valid data updates the objective" do
      objective = objective_fixture()

      update_attrs = %{
        year: 43,
        subject: "some updated subject",
        grade: "some updated grade",
        goal: "some updated goal"
      }

      assert {:ok, %Objective{} = objective} =
               Curriculum.update_objective(objective, update_attrs)

      assert objective.year == 43
      assert objective.subject == "some updated subject"
      assert objective.grade == "some updated grade"
      assert objective.goal == "some updated goal"
    end

    test "update_objective/3 with invalid data returns error changeset" do
      objective = objective_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Curriculum.update_objective(objective, @invalid_attrs)

      assert objective == Curriculum.get_objective!(objective.id)
    end

    test "delete_objective/2 deletes the objective" do
      objective = objective_fixture()
      assert {:ok, %Objective{}} = Curriculum.delete_objective(objective)
      assert_raise Ecto.NoResultsError, fn -> Curriculum.get_objective!(objective.id) end
    end

    test "change_objective/2 returns a objective changeset" do
      objective = objective_fixture()
      assert %Ecto.Changeset{} = Curriculum.change_objective(objective)
    end
  end
end

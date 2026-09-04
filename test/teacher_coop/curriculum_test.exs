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

  describe "search_objectives/1" do
    import TeacherCoop.SearchRepo, only: [get_client: 0]

    alias TeacherCoop.SearchRepo.SearchObjectives

    # `search_objectives/1` queries the (non-sandboxed) "objectives" Meilisearch
    # index directly. Index a uniquely-named objective for the duration of the
    # test and drop it again afterwards so the shared index does not leak.
    defp index_objective!(attrs) do
      attrs =
        Enum.into(attrs, %{
          id: System.unique_integer([:positive]),
          year: 2024,
          subject: "some subject",
          grade: "some grade",
          strand: "some strand"
        })

      assert :ok = SearchObjectives.index_objective(attrs, true)
      on_exit(fn -> Meilisearch.Document.delete_one(get_client(), "objectives", attrs.id) end)
      attrs
    end

    test "returns the hits matching the search terms" do
      term = "photosynthesexyz"
      objective = index_objective!(%{goal: "comprendre la #{term} des plantes"})

      hits = Curriculum.search_objectives(term)

      assert is_list(hits)
      assert [%{"id" => id}] = Enum.filter(hits, &(&1["id"] == objective.id))
      assert id == objective.id
    end

    test "returns an empty list when nothing matches" do
      assert Curriculum.search_objectives("zzz-no-such-objective-zzz") == []
    end

    test "raises for a non-string input" do
      not_a_string = Enum.random([nil])
      assert_raise FunctionClauseError, fn -> Curriculum.search_objectives(not_a_string) end
    end
  end
end

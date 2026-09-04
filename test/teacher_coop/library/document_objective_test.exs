defmodule TeacherCoop.Library.DocumentObjectiveTest do
  use TeacherCoop.DataCase, async: true

  import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
  import TeacherCoop.LibraryFixtures
  import TeacherCoop.CurriculumFixtures

  alias TeacherCoop.Library.DocumentObjective

  describe "changeset/2" do
    test "is valid with document_id and objective_id" do
      changeset = DocumentObjective.changeset(%DocumentObjective{}, %{document_id: 1, objective_id: 2})

      assert changeset.valid?
      assert get_change(changeset, :document_id) == 1
      assert get_change(changeset, :objective_id) == 2
    end

    test "requires document_id and objective_id" do
      changeset = DocumentObjective.changeset(%DocumentObjective{}, %{})

      refute changeset.valid?

      assert %{
               document_id: ["can't be blank"],
               objective_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "is invalid without document_id" do
      changeset = DocumentObjective.changeset(%DocumentObjective{}, %{objective_id: 2})

      refute changeset.valid?
      assert %{document_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "is invalid without objective_id" do
      changeset = DocumentObjective.changeset(%DocumentObjective{}, %{document_id: 1})

      refute changeset.valid?
      assert %{objective_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "casts an explicit id" do
      changeset =
        DocumentObjective.changeset(%DocumentObjective{}, %{
          id: 10,
          document_id: 1,
          objective_id: 2
        })

      assert get_change(changeset, :id) == 10
    end
  end

  describe "database constraints" do
    setup do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      objective = objective_fixture()

      %{document: document, objective: objective}
    end

    test "inserts a link between a document and an objective", %{
      document: document,
      objective: objective
    } do
      assert {:ok, document_objective} =
               %DocumentObjective{}
               |> DocumentObjective.changeset(%{
                 document_id: document.id,
                 objective_id: objective.id
               })
               |> Repo.insert()

      assert document_objective.document_id == document.id
      assert document_objective.objective_id == objective.id
    end

    test "enforces the foreign key on document_id", %{objective: objective} do
      assert {:error, changeset} =
               %DocumentObjective{}
               |> DocumentObjective.changeset(%{
                 document_id: -1,
                 objective_id: objective.id
               })
               |> Repo.insert()

      assert %{document_id: ["does not exist"]} = errors_on(changeset)
    end

    test "enforces the foreign key on objective_id", %{document: document} do
      assert {:error, changeset} =
               %DocumentObjective{}
               |> DocumentObjective.changeset(%{
                 document_id: document.id,
                 objective_id: -1
               })
               |> Repo.insert()

      assert %{objective_id: ["does not exist"]} = errors_on(changeset)
    end

    test "prevents duplicate document/objective pairs", %{
      document: document,
      objective: objective
    } do
      attrs = %{document_id: document.id, objective_id: objective.id}

      assert {:ok, _} =
               %DocumentObjective{} |> DocumentObjective.changeset(attrs) |> Repo.insert()

      assert {:error, changeset} =
               %DocumentObjective{} |> DocumentObjective.changeset(attrs) |> Repo.insert()

      assert %{document_id: ["has already been taken"]} = errors_on(changeset)
    end
  end
end

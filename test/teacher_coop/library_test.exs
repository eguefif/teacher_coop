defmodule TeacherCoop.LibraryTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Library

  describe "documents" do
    alias TeacherCoop.Library.Document

    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeacherCoop.LibraryFixtures

    @invalid_attrs %{description: nil, title: nil, institution_type: "wrong", grade: "wrong"}

    test "list_documents/1 returns all scoped documents" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      document = document_fixture(scope)
      other_document = document_fixture(other_scope)
      assert Library.list_documents(scope) == [document]
      assert Library.list_documents(other_scope) == [other_document]
    end

    test "get_document!/2 returns the document with given id" do
      scope = user_scope_fixture()
      document = document_fixture(scope)

      document =
        document
        |> Map.filter(&(elem(&1, 0) != :files))
        |> Map.filter(&(elem(&1, 0) != :document_objectives))

      expected_document =
        Library.get_document!(document.id)
        |> Map.filter(&(elem(&1, 0) != :files))
        |> Map.filter(&(elem(&1, 0) != :document_objectives))

      assert expected_document == document
      assert_raise Ecto.NoResultsError, fn -> Library.get_document!(document.id + 1) end
    end

    test "create_document/2 with valid data creates a document" do
      institution_type = Document.institution_types_options() |> Enum.at(0)

      valid_attrs = %{
        description: "some description",
        title: "some title",
        institution_type: institution_type,
        grade: "CM2"
      }

      scope = user_scope_fixture()

      assert {:ok, %Document{} = document} = Library.create_document(scope, valid_attrs)
      assert document.description == "some description"
      assert document.title == "some title"
      assert document.institution_type == institution_type
      assert document.user_id == scope.user.id
    end

    test "create_document/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Library.create_document(scope, @invalid_attrs)
    end

    test "update_document/3 with valid data updates the document" do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      update_attrs = %{description: "some updated description", title: "some updated title"}

      assert {:ok, %Document{} = document} =
               Library.update_document(scope, document, update_attrs)

      assert document.description == "some updated description"
      assert document.title == "some updated title"
    end

    test "update_document/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      document = document_fixture(scope)

      assert_raise MatchError, fn ->
        Library.update_document(other_scope, document, %{})
      end
    end

    test "update_document/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      document = document_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Library.update_document(scope, document, @invalid_attrs)

      document =
        document
        |> Map.filter(&(elem(&1, 0) != :files))
        |> Map.filter(&(elem(&1, 0) != :document_objectives))

      expected_document =
        Library.get_document!(document.id)
        |> Map.filter(&(elem(&1, 0) != :files))
        |> Map.filter(&(elem(&1, 0) != :document_objectives))

      assert document == expected_document
    end

    test "delete_document/2 deletes the document" do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      document = Repo.get(Document, document.id) |> Repo.preload(:files)
      assert {:ok, %Document{}} = Library.delete_document(scope, document)
      assert_raise Ecto.NoResultsError, fn -> Library.get_document!(document.id) end
    end

    test "delete_document/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      document = document_fixture(scope)
      assert_raise MatchError, fn -> Library.delete_document(other_scope, document) end
    end

    test "change_document/2 returns a document changeset" do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      assert %Ecto.Changeset{} = Library.change_document(scope, document)
    end

    test "change_document/2 returns error with invalid institution_types" do
      scope = user_scope_fixture()

      attrs = %{
        title: "test",
        description: "test",
        institution_type: "wrong type",
        grade: "CM2"
      }

      changeset = Document.changeset(%Document{}, attrs, scope)
      assert changeset.valid? == false
      assert List.keymember?(changeset.errors, :institution_type, 0)
    end

    test "change_document/2 returns error with invalid grade" do
      scope = user_scope_fixture()

      attrs = %{
        title: "test",
        description: "test",
        institution_type: "Tout le monde",
        grade: "wrong"
      }

      changeset = Document.changeset(%Document{}, attrs, scope)
      assert changeset.valid? == false
      assert List.keymember?(changeset.errors, :grade, 0)
    end
  end
end

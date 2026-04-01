defmodule TeacherCoop.WorkspaceTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Workspace

  describe "documents" do
    alias TeacherCoop.Workspace.Document

    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeacherCoop.WorkspaceFixtures

    @invalid_attrs %{title: nil}

    test "list_documents/1 returns all scoped documents" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      document = document_fixture(scope)
      other_document = document_fixture(other_scope)
      assert Workspace.list_documents(scope) == [document]
      assert Workspace.list_documents(other_scope) == [other_document]
    end

    test "get_document!/2 returns the document with given id" do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      other_scope = user_scope_fixture()
      assert Workspace.get_document!(scope, document.id) == document
      assert_raise Ecto.NoResultsError, fn -> Workspace.get_document!(other_scope, document.id) end
    end

    test "create_document/2 with valid data creates a document" do
      valid_attrs = %{title: "some title"}
      scope = user_scope_fixture()

      assert {:ok, %Document{} = document} = Workspace.create_document(scope, valid_attrs)
      assert document.title == "some title"
      assert document.user_id == scope.user.id
    end

    test "create_document/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Workspace.create_document(scope, @invalid_attrs)
    end

    test "update_document/3 with valid data updates the document" do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Document{} = document} = Workspace.update_document(scope, document, update_attrs)
      assert document.title == "some updated title"
    end

    test "update_document/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      document = document_fixture(scope)

      assert_raise MatchError, fn ->
        Workspace.update_document(other_scope, document, %{})
      end
    end

    test "update_document/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Workspace.update_document(scope, document, @invalid_attrs)
      assert document == Workspace.get_document!(scope, document.id)
    end

    test "delete_document/2 deletes the document" do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      assert {:ok, %Document{}} = Workspace.delete_document(scope, document)
      assert_raise Ecto.NoResultsError, fn -> Workspace.get_document!(scope, document.id) end
    end

    test "delete_document/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      document = document_fixture(scope)
      assert_raise MatchError, fn -> Workspace.delete_document(other_scope, document) end
    end

    test "change_document/2 returns a document changeset" do
      scope = user_scope_fixture()
      document = document_fixture(scope)
      assert %Ecto.Changeset{} = Workspace.change_document(scope, document)
    end
  end
end

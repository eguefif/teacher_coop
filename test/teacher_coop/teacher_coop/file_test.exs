defmodule TeacherCoop.TeacherCoop.FileTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.TeacherCoop.File

  describe "files" do
    alias TeacherCoop.TeacherCoop.File.File

    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 0]
    import TeacherCoop.TeacherCoop.FileFixtures

    @invalid_attrs %{filename: nil, path: nil}

    test "list_files/1 returns all scoped files" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      file = file_fixture(scope)
      other_file = file_fixture(other_scope)
      assert File.list_files(scope) == [file]
      assert File.list_files(other_scope) == [other_file]
    end

    test "get_file!/2 returns the file with given id" do
      scope = user_scope_fixture()
      file = file_fixture(scope)
      other_scope = user_scope_fixture()
      assert File.get_file!(scope, file.id) == file
      assert_raise Ecto.NoResultsError, fn -> File.get_file!(other_scope, file.id) end
    end

    test "create_file/2 with valid data creates a file" do
      valid_attrs = %{filename: "some filename", path: "some path"}
      scope = user_scope_fixture()

      assert {:ok, %File{} = file} = File.create_file(scope, valid_attrs)
      assert file.filename == "some filename"
      assert file.path == "some path"
      assert file.user_id == scope.user.id
    end

    test "create_file/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = File.create_file(scope, @invalid_attrs)
    end

    test "update_file/3 with valid data updates the file" do
      scope = user_scope_fixture()
      file = file_fixture(scope)
      update_attrs = %{filename: "some updated filename", path: "some updated path"}

      assert {:ok, %File{} = file} = File.update_file(scope, file, update_attrs)
      assert file.filename == "some updated filename"
      assert file.path == "some updated path"
    end

    test "update_file/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      file = file_fixture(scope)

      assert_raise MatchError, fn ->
        File.update_file(other_scope, file, %{})
      end
    end

    test "update_file/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      file = file_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = File.update_file(scope, file, @invalid_attrs)
      assert file == File.get_file!(scope, file.id)
    end

    test "delete_file/2 deletes the file" do
      scope = user_scope_fixture()
      file = file_fixture(scope)
      assert {:ok, %File{}} = File.delete_file(scope, file)
      assert_raise Ecto.NoResultsError, fn -> File.get_file!(scope, file.id) end
    end

    test "delete_file/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      file = file_fixture(scope)
      assert_raise MatchError, fn -> File.delete_file(other_scope, file) end
    end

    test "change_file/2 returns a file changeset" do
      scope = user_scope_fixture()
      file = file_fixture(scope)
      assert %Ecto.Changeset{} = File.change_file(scope, file)
    end
  end
end

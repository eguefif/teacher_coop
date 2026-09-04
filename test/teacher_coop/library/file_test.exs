defmodule TeacherCoop.Library.FileTest do
  use TeacherCoop.DataCase, async: true

  alias TeacherCoop.Library.File

  @valid_attrs %{
    filename: "lesson.pdf",
    filepath: "uploads/lesson.pdf",
    format: "pdf"
  }

  describe "changeset/2" do
    test "is valid with filename, filepath and format" do
      changeset = File.changeset(%File{}, @valid_attrs)

      assert changeset.valid?
      assert get_change(changeset, :filename) == "lesson.pdf"
      assert get_change(changeset, :filepath) == "uploads/lesson.pdf"
      assert get_change(changeset, :format) == "pdf"
    end

    test "requires filename, filepath and format" do
      changeset = File.changeset(%File{}, %{})

      refute changeset.valid?

      assert %{
               filename: ["can't be blank"],
               filepath: ["can't be blank"],
               format: ["can't be blank"]
             } = errors_on(changeset)
    end

    for field <- [:filename, :filepath, :format] do
      test "is invalid when #{field} is missing" do
        changeset = File.changeset(%File{}, Map.delete(@valid_attrs, unquote(field)))

        refute changeset.valid?
        assert %{unquote(field) => ["can't be blank"]} = errors_on(changeset)
      end
    end

    test "ignores fields that are not permitted" do
      changeset =
        File.changeset(%File{}, Map.put(@valid_attrs, :document_id, 123))

      assert changeset.valid?
      assert get_change(changeset, :document_id) == nil
    end
  end
end

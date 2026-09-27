defmodule TeacherCoop.CurriculumTest.IngestionTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Curriculum.Ingestion

  @valid_attrs %{grade: "cp", subject: "français", file_content: "Some content"}
  @invalid_attrs %{grade: "cpp", subject: "français", file_content: "Some content"}

  describe "Ingestion" do
    test "changeset/2" do
      changeset = Ingestion.changeset(%Ingestion{}, @valid_attrs)

      assert changeset.valid?
    end

    test "changeset/2 not valid because of grade" do
      changeset = Ingestion.changeset(%Ingestion{}, @invalid_attrs)

      assert changeset.valid? == false
      assert length(changeset.errors) != 0
    end
  end
end

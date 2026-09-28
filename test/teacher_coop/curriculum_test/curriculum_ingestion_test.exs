defmodule TeacherCoop.CurriculumTest.CurriculumCurriculumIngestionTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Curriculum.CurriculumIngestion

  @valid_attrs %{year: 2020, subject: "français", file_content: "Some content"}
  @invalid_attrs %{year: 2022, subject: "relou", file_content: "Some content"}

  describe "CurriculumIngestion" do
    test "changeset/2" do
      changeset = CurriculumIngestion.changeset(%CurriculumIngestion{}, @valid_attrs)

      assert changeset.valid?
    end

    test "changeset/2 not valid because of grade" do
      changeset = CurriculumIngestion.changeset(%CurriculumIngestion{}, @invalid_attrs)

      assert changeset.valid? == false
      assert length(changeset.errors) != 0
    end
  end
end

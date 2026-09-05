defmodule TeacherCoop.Library.WorkersTest do
  use ExUnit.Case, async: true
  use TeacherCoop.DataCase

  alias TeacherCoop.Library.Workers.IndexDocument
  alias TeacherCoop.Library.Workers.DeleteDocument
  alias TeacherCoop.Library.Workers.DeleteFiles

  describe "IndexDocument" do
    test "perform_job/1 index a new document" do
      attrs = %{}
      assert :ok = perform_job(IndexDocument, %{attrs: attrs})
    end
  end

  describe "DeleteDocument" do
    test "perform_job/1 deletes a document" do
      assert :ok = perform_job(DeleteDocument, %{document_id: "some-document-id"})
    end
  end

  describe "DeleteFiles" do
    test "perform_job/1 deletes the given files from disc" do
      base_path = File.cwd!() <> "/priv/static/"
      relative_path = "files/delete_files_worker_test.txt"
      File.write!(base_path <> relative_path, "some content")

      assert :ok = perform_job(DeleteFiles, %{files: [relative_path]})
      refute File.exists?(base_path <> relative_path)
    end
  end
end

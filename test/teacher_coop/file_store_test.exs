defmodule TeacherCoop.FileStoretest do
  use TeacherCoop.DataCase
  alias TeacherCoop.FileStore

  test "get_file_url/2" do
    key = "/path/my_file.pdf"
    url = FileStore.get_file_url(key, expires_in: 600)
    assert url
    assert String.contains?(url, key)
  end

  test "create_file_url/2" do
    {result, meta} =
      FileStore.create_file_url("my_file.pdf", "",
        expires_in: 600,
        max_file_size: 15_000_000,
        content_type: "application/pdf"
      )

    assert result == :ok
    assert Map.get(meta.fields, "acl", nil) == "private"

    assert meta.key == "teachercoop_documents/my_file.pdf"
    assert meta.url == "http://localhost:9090/teachercoop"
    assert meta.uploader == "S3"
  end
end

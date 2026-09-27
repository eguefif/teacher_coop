defmodule TeacherCoopWeb.FileController do
  use TeacherCoopWeb, :controller

  alias TeacherCoop.FileStore
  alias TeacherCoop.Library

  def show(conn, %{"id" => id, "preview" => "true"}) do
    file = Library.get_file!(id)
    url = get_file_content(:compressed, file.filename)
    redirect(conn, external: url)
  end

  def show(conn, %{"id" => id}) do
    file = Library.get_file!(id)

    url = get_file_content(:regular, file.filename)
    redirect(conn, external: url)
  end

  defp get_file_content(:compressed, file_path) do
    compressed_file_path = file_path <> "-compressed"

    FileStore.get_file_url(compressed_file_path, expires_in: 600)
  end

  defp get_file_content(:regular, file_path) do
    FileStore.get_file_url(file_path, expires_in: 600)
  end
end

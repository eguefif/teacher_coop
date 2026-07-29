defmodule TeacherCoopWeb.FileController do
  use TeacherCoopWeb, :controller

  alias TeacherCoop.Library

  def get(conn, %{"id" => id}) do
    file = Library.get_file!(id)
    file_content = File.read!("./priv/static/" <> file.filepath)

    conn
    |> put_resp_content_type(get_content_type(file.format))
    |> put_resp_header("content-disposition", "attachement; filename=\"#{file.filename}\"")
    |> put_root_layout(false)
    |> send_resp(200, file_content)
  end

  defp get_content_type(format) do
    case format do
      "pdf" -> "application/pdf"
      "docx" -> "application/docx"
    end
  end
end

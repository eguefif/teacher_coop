defmodule TeacherCoopWeb.FileController do
  use TeacherCoopWeb, :controller

  alias TeacherCoop.Library

  def show(conn, %{"id" => id, "preview" => "true"}) do
    file = Library.get_file!(id)

    file_content = get_file_content(:compressed, file.filepath)

    conn
    |> base_resp("inline", file)
    |> send_resp(200, file_content)
  end

  def show(conn, %{"id" => id}) do
    file = Library.get_file!(id)
    file_content = get_file_content(:regular, file.filepath)

    conn
    |> base_resp("attachment", file)
    |> send_resp(200, file_content)
  end

  defp base_resp(conn, disposition, file) do
    conn
    |> put_resp_content_type(get_content_type(file.format))
    |> put_resp_header("content-disposition", "#{disposition}; filename=\"#{file.filename}\"")
    |> put_root_layout(false)
  end

  defp get_content_type(format) do
    case format do
      "pdf" -> "application/pdf"
      "docx" -> "application/docx"
    end
  end

  defp get_file_content(:compressed, file_path) do
    cwd = Application.app_dir(:teacher_coop, "priv/static")
    compressed_file_path = Path.join(cwd, file_path <> "-compressed")
    file_path = Path.join(cwd, file_path)

    case File.read(compressed_file_path) do
      {:ok, content} ->
        content

      {:error, :enoent} ->
        File.read!(file_path)
    end
  end

  defp get_file_content(:regular, file_path) do
    cwd = Application.app_dir(:teacher_coop, "priv/static")
    file_path = Path.join(cwd, file_path)
    File.read!(file_path)
  end
end

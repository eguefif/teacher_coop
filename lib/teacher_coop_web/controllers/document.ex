defmodule TeacherCoopWeb.DocumentController do
  use TeacherCoopWeb, :controller

  alias TeacherCoop.Library

  def show(conn, %{"id" => id}) do
    id = String.to_integer(id)
    document = Library.get_document!(id)
    cwd = Application.app_dir(:teacher_coop, "priv/static")

    files =
      document.files
      |> Enum.map(&{String.to_charlist(&1.filename), &1.filepath})
      |> Enum.map(&{elem(&1, 0), Path.join(cwd, elem(&1, 1))})
      |> Enum.map(&{elem(&1, 0), File.read!(elem(&1, 1))})

    {:ok, {filename, content}} =
      :zip.zip(String.to_charlist(document.title <> ".zip"), files, [:memory])

    conn
    |> put_resp_content_type("application/zip")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> put_root_layout(false)
    |> send_resp(200, content)
  end
end

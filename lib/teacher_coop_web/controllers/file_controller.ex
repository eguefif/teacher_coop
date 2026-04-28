defmodule TeacherCoopWeb.FileController do
  use TeacherCoopWeb, :controller

  def download(conn, %{"id" => id}) do
    file = TeacherCoop.Workspace.get_file!(conn.assigns.current_scope, id)
    send_download(conn, {:file, file.path}, filename: file.filename)
  end
end

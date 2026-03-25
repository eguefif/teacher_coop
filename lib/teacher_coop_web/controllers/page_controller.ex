defmodule TeacherCoopWeb.PageController do
  use TeacherCoopWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

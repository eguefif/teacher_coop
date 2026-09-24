defmodule TeacherCoopWeb.HealthController do
  use TeacherCoopWeb, :controller

  def show(conn, _params) do
    json(conn, %{status: "healthy"})
  end
end

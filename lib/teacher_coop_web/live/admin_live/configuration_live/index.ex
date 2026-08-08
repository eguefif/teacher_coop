defmodule TeacherCoopWeb.AdminLive.ConfigurationLive.Index do
  use TeacherCoopWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>Admin</div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    IO.inspect(session)

    {:ok, socket}
  end
end

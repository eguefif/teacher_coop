defmodule TeacherCoopWeb.WorkspaceLive.Workspace do
  use TeacherCoopWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div clas="mx-auto">
        <.button navigate={~p"/workspace/documents"}>{gettext("My Documents")}</.button>
      </div>
    </Layouts.app>
    """
  end
end

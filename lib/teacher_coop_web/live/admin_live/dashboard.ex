defmodule TeacherCoopWeb.AdminLive.DashboardLive do
  use TeacherCoopWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {gettext("Dashboard")}
      </.header>
      <div>
        <.live_component
          module={TeacherCoopWeb.AdminLive.DocumentsCountLive}
          id={@documents_count_component_id}
          current_scope={@current_scope}
        />
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:documents_count_component_id, "documents-count")}
  end
end

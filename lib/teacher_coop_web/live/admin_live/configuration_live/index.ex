defmodule TeacherCoopWeb.AdminLive.ConfigurationLive.Index do
  use TeacherCoopWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Index Configurations")}
        <:actions>
          <.button variant="primary" navigate={~p"/admin/configuration/new"}>
            <.icon name="hero-plus" /> {gettext("New")} {gettext("Index")}
          </.button>
        </:actions>
      </.header>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

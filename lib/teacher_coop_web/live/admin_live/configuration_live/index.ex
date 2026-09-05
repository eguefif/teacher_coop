defmodule TeacherCoopWeb.AdminLive.ConfigurationLive.Index do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Discovery.Configuration

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Index Configurations")}
        <:actions>
          <.button variant="primary" navigate={~p"/admin/configurations/new"}>
            <.icon name="hero-plus" /> {gettext("New")} {gettext("Index")}
          </.button>
        </:actions>
      </.header>

      <.table
        id="configurations"
        rows={@streams.configurations}
        row_click={
          fn {_id, configuration} -> JS.navigate(~p"/admin/configurations/#{configuration}") end
        }
      >
        <:col :let={{_id, configuration}} label={gettext("Configuration Name")}>
          {configuration.name}
        </:col>
        <:action :let={{_id, configuration}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/configurations/#{configuration}"}>{gettext("Show")}</.link>
          </div>
          <.link navigate={~p"/admin/configurations/#{configuration}/edit"}>{gettext("Edit")}</.link>
        </:action>
        <:action :let={{id, configuration}}>
          <.link
            phx-click={JS.push("delete", value: %{id: configuration.id}) |> hide("##{id}")}
            data-confirm={gettext("Are you sure?")}
          >
            {gettext("Delete")}
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    configurations = Configuration.list_configurations(socket.assigns.current_scope)

    {:ok,
     socket
     |> stream(:configurations, configurations)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    configuration = Configuration.get_configuration!(socket.assigns.current_scope, id)

    {:ok, _} =
      Configuration.delete_configuration(socket.assigns.current_scope, configuration)

    {:noreply, stream_delete(socket, :configurations, configuration)}
  end
end

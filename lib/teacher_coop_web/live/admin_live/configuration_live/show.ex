defmodule TeacherCoopWeb.AdminLive.ConfigurationLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Discovery.Configuration

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@configuration.index_name}
        <:actions>
          <.button variant="primary" navigate={~p"/admin/configurations/#{@configuration.id}/edit"}>
            <.icon name="hero-plus" /> {gettext("Edit")} {gettext("Index")}
          </.button>
        </:actions>
      </.header>
      <pre><%= inspect @configuration, pretty: true %></pre>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    id = String.to_integer(params["id"])
    configuration = Configuration.get_configuration!(id)

    {:ok,
     socket
     |> assign(:configuration, configuration)}
  end
end

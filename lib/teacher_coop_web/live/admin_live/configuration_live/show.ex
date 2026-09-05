defmodule TeacherCoopWeb.AdminLive.ConfigurationLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Discovery.Configuration

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Configuration {@configuration.name} ({@configuration.engine |> String.capitalize()})
        <:actions>
          <.button navigate={~p"/admin/configurations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/configurations/#{@configuration.id}/edit"}>
            <.icon name="hero-plus" /> {gettext("Edit")} {gettext("Index")}
          </.button>
        </:actions>
      </.header>
      <div class="flex flex-col gap-2">
        <div>
          <pre class="bg-base-200 p-4 rounded overflow-x-auto text-sm">{Jason.encode!(@configuration.config |> Ecto.embedded_dump(:json), pretty: true)}</pre>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    id = String.to_integer(params["id"])
    configuration = Configuration.get_configuration!(socket.assigns.current_scope, id)

    {:ok,
     socket
     |> assign(:configuration, configuration)}
  end
end

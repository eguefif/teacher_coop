defmodule TeacherCoopWeb.AdminLive.IndexLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Discovery.Configuration

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Index")} {@index.name}
        <:actions>
          <.button navigate={~p"/admin/indexes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/indexes/#{@index.id}/edit"}>
            <.icon name="hero-pencil-square" /> {gettext("Edit")}
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title={gettext("Name")}>{@index.name}</:item>
        <:item title={gettext("Primary key")}>{@index.primary_key}</:item>
        <:item title={gettext("Type")}>{@index.type}</:item>
        <:item title={gettext("State")}>{@index.state || gettext("Unknown")}</:item>
        <:item title={gettext("Task uid")}>{@index.task_uid || "-"}</:item>
        <:item title={gettext("Configuration")}>
          {config_label(@index.engine_configuration)}
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    index = Configuration.get_index!(id, socket.assigns.current_scope)

    {:ok, assign(socket, :index, index)}
  end

  defp config_label(%{name: name}), do: name
  defp config_label(_), do: gettext("No config")
end

defmodule TeacherCoopWeb.AdminLive.IndexLive.Index do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Discovery.Configuration

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Index")}
      </.header>

      <.table
        id="indexes"
        rows={@streams.indexes}
      >
        <:col :let={{_id, index}} label={gettext("Name")}>
          {index.name}
        </:col>
        <:col :let={{_id, index}} label={gettext("Config")}>
          {index.config || gettext("No config")}
        </:col>
        <:action :let={{_id, _index}}>
          {gettext("Apply config")}
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    indexes =
      Configuration.list_index_names()

    IO.inspect(indexes)

    {:ok,
     socket
     |> stream(:indexes, indexes)}
  end

  defp get_config(indexname, configurations) do
    configurations
    |> Enum.find(%{}, &(indexname in &1.index_names))
    |> Map.get(:name)
  end
end

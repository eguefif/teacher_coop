defmodule TeacherCoopWeb.AdminLive.IndexLive.Index do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Discovery.Configuration

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Listing Index")}
        <:actions>
          <.button variant="primary" navigate={~p"/admin/indexes/new"}>
            <.icon name="hero-plus" /> {gettext("New Index")}
          </.button>
        </:actions>
      </.header>

      <.table
        id="indexes"
        rows={@streams.indexes}
        row_click={fn {_id, index} -> JS.navigate(~p"/admin/indexes/#{index}") end}
      >
        <:col :let={{_id, index}} label={gettext("Name")}>
          {index.uid}
        </:col>
        <:col :let={{_id, index}} label={gettext("Config")}>
          {get_engine_configuration_name_or_default(index.engine_configuration)}
        </:col>
        <:col :let={{_id, index}} label={gettext("State")}>
          <div class={[
            "badge",
            index.state == "indexed" && "badge-success",
            index.state == "indexing" && "badge-warning",
            index.state == "error_indexing" && "badge-error"
          ]}>
            {index.state}
          </div>
        </:col>
        <:action :let={{_id, index}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/indexes/#{index}"}>{gettext("Show")}</.link>
          </div>
          <.link navigate={~p"/admin/indexes/#{index}/edit"}>{gettext("Edit")}</.link>
        </:action>
        <:action :let={{id, index}}>
          <.link
            id={"delete-#{index.id}"}
            phx-click={JS.push("delete", value: %{id: index.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  defp get_engine_configuration_name_or_default(value) when is_nil(value),
    do: gettext("No Config")

  defp get_engine_configuration_name_or_default(engine_configuration),
    do: engine_configuration.name

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Configuration.subscribe_index()

    indexes =
      Configuration.list_index(socket.assigns.current_scope)

    {:ok,
     socket
     |> stream(:indexes, indexes)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    index = Configuration.get_index!(id, socket.assigns.current_scope)

    case Configuration.delete_index(index, socket.assigns.current_scope) do
      {:ok, index} ->
        {:noreply, stream_delete(socket, :indexes, index)}

      {:error, error} ->
        {:noreply,
         socket |> put_flash(:error, gettext("Impossible to delete index") <> ": " <> error)}
    end
  end

  @impl true
  def handle_info({:index_updated, index}, socket) do
    {:noreply, stream_insert(socket, :indexes, index)}
  end
end

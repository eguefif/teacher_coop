defmodule TeacherCoopWeb.WorkspaceLive.ConnectionLive.Index do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace.TeacherNetworking
  alias TeacherCoop.Accounts
  alias TeacherCoopWeb.Reusables

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header return={~p"/workspace/"}>
        {gettext("Manage My Connections")}
      </.header>
      <div class="flex flex-col gap-8">
        <.live_component
          module={Reusables.AutocompleteInput}
          id="teacher-search"
          name="teacher-search"
          placeholder={gettext("Search new connections")}
          allow_input_edit={false}
          autocomplete_list={@autocomplete}
          on_user_typing={fn input_value -> send(self(), {:user_typing, input_value}) end}
          on_autocomplete_submit={fn connection -> send(self(), {:add_connection, connection}) end}
        />
        <div class="flex flex-col gap-2 w-100 m-auto">
          <div
            :for={connection <- @new_connections_list}
            class="rounded-box shadow shadow-md p-2 flex flex-row gap-2 items-baseline"
          >
            {connection.value}
            <.button
              type="button"
              phx-click="user-invite-connection"
              phx-value-id={connection.id}
              class="btn btn-soft ml-auto btn-primary"
            >
              {gettext("Invite")}
            </.button>
            <.button
              type="button"
              phx-click="user-remove-connection-from-new-list"
              phx-value-id={connection.id}
              class="btn btn-ghost"
            >
              X
            </.button>
          </div>
        </div>

        <div class="divider"></div>

        <div class="flex flex-col gap-8">
          <div class="list rounded-box shadow-md">
            <div
              :for={connection <- @connections}
              class="list-row w-full place-items-baseline"
            >
              <div>
                {connection.fullname}
              </div>
              <div class="flex flex-row ml-auto w-35 justify-between items-baseline">
                <div class={[
                  "badge badge-soft rounded-xl",
                  connection.state == "pending" && "badge-accent",
                  connection.state == "accepted" && "badge-success",
                  connection.state == "rejected" && "badge-error"
                ]}>
                  {connection.state}
                </div>
                <.button
                  type="button"
                  phx-click="user-remove-connection"
                  phx-value-id={connection.connection_id}
                  data-confirm={gettext("Are you sure you want to remove this connections?")}
                  class="btn btn-soft btn-warning"
                >
                  X
                </.button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _sessions, socket) do
    connections = get_ordered_connections(socket)

    {:ok,
     socket
     |> assign(:autocomplete, [])
     |> assign(:connections, connections)
     |> assign(:new_connections_list, [])}
  end

  @impl true
  def handle_info({:add_connection, connection}, socket) do
    new_list = socket.assigns.new_connections_list ++ [connection]
    IO.inspect(new_list)
    {:noreply, socket |> assign(:new_connections_list, new_list)}
  end

  @impl true
  def handle_info({:user_typing, input_value}, socket) do
    new_list =
      Accounts.search_user(socket.assigns.current_scope, input_value)
      |> Enum.map(fn entry -> %{id: entry.id, value: entry.fullname} end)

    IO.inspect(new_list)
    {:noreply, socket |> assign(:autocomplete, new_list)}
  end

  @impl true
  def handle_event("user-remove-connection-from-new-list", %{"id" => id}, socket) do
    new_list =
      Enum.reject(socket.assigns.new_connections_list, fn entry ->
        entry.id == String.to_integer(id)
      end)

    {:noreply, socket |> assign(:new_connections_list, new_list)}
  end

  @impl true
  def handle_event("user-invite-connection", %{"id" => id}, socket) do
    id = String.to_integer(id)

    new_list =
      case TeacherNetworking.create_pending_connection(socket.assigns.current_scope, id) do
        :already_pending_connection ->
          socket.assigns.new_connections_list

        {:ok, _} ->
          Enum.reject(socket.assigns.new_connections_list, fn entry -> entry.id == id end)
      end

    connections = get_ordered_connections(socket)

    {:noreply,
     socket |> assign(:new_connections_list, new_list) |> assign(:connections, connections)}
  end

  def handle_event("user-remove-connection", %{"id" => id}, socket) do
    TeacherNetworking.remove_connection_by_id(socket.assigns.current_scope, id)
    connections = TeacherNetworking.get_connections(socket.assigns.current_scope)
    {:noreply, socket |> assign(:connections, connections)}
  end

  defp get_ordered_connections(socket) do
    TeacherNetworking.get_connections(socket.assigns.current_scope)
    |> Enum.sort(fn a, b ->
      case {a.state, b.state} do
        {"rejected", _} -> true
        {"pending", "accepted"} -> true
        _ -> false
      end
    end)
  end
end

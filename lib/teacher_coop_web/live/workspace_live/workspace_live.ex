defmodule TeacherCoopWeb.WorkspaceLive.Workspace do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.TeacherNetworking

  # TODO: add group invitation, allow to accept or reject

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col gap-12">
        <div class="flex flex-row gap-8 justify-between">
          <div class="mx-auto">
            <.button navigate={~p"/workspace/documents"}>{gettext("My Documents")}</.button>
          </div>

          <div class="mx-auto">
            <.button navigate={~p"/workspace/groups"}>{gettext("My Groups")}</.button>
          </div>

          <div class="mx-auto">
            <.button navigate={~p"/workspace/colleagues"}>{gettext("My Colleagues")}</.button>
          </div>
        </div>
        <div :if={@pending_connections != []}>
          <h1>{gettext("Connection Requests")}</h1>
          <ul class="list">
            <li
              :for={connection <- @pending_connections}
              class="list-row flex-row justify-around items-baseline"
            >
              {connection[:fullname]}
              <div>
                <.button
                  type="button"
                  phx-click="accept-connection-request"
                  phx-value-ref={connection[:id]}
                  variant="primary"
                >
                  {gettext("Accept")}
                </.button>
                <.button
                  type="button"
                  phx-click="reject-connection-request"
                  phx-value-ref={connection[:id]}
                >
                  {gettext("Reject")}
                </.button>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    pending_connections = TeacherNetworking.get_pending_connections(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:pending_connections, pending_connections)}
  end

  @impl true
  def handle_event("accept-connection-request", %{"ref" => id}, socket) do
    case TeacherNetworking.update_connection(socket.assigns.current_scope, :accept, id) do
      {:ok, _} ->
        pending_connections =
          TeacherNetworking.get_pending_connections(socket.assigns.current_scope)

        {:noreply,
         socket
         |> assign(:pending_connections, pending_connections)
         |> put_flash(:info, gettext("Connection request accepted"))}

      :error ->
        {:noreply, socket |> put_flash(:error, gettext("An error occured, retry later."))}
    end
  end

  @impl true
  def handle_event("reject-connection-request", %{"ref" => id}, socket) do
    case TeacherNetworking.update_connection(socket.assigns.current_scope, :reject, id) do
      {:ok, _} ->
        pending_connections =
          TeacherNetworking.get_pending_connections(socket.assigns.current_scope)

        {:noreply,
         socket
         |> assign(:pending_connections, pending_connections)
         |> put_flash(:info, gettext("Connection request rejected"))}

      :error ->
        {:noreply, socket |> put_flash(:error, gettext("An error occured, retry later."))}
    end
  end
end

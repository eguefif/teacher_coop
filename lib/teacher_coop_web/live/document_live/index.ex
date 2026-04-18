defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Index do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @live_action in [:new, :edit] do %>
      <.live_component
        module={WorkspaceLive.DocumentLive.FormComponent}
        id={@document || :new}
        action={@live_action}
        current_scope={@current_scope}
      />
    <% else %>
      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <.header>
          {gettext("Listing Documents")}
          <:actions>
            <.button variant="primary" navigate={~p"/workspace/documents/new"}>
              <.icon name="hero-plus" /> {gettext("New Document")}
            </.button>
          </:actions>
        </.header>

        <.table
          id="documents"
          rows={@streams.documents}
          row_click={fn {_id, document} -> JS.navigate(~p"/workspace/documents/#{document}") end}
        >
          <:col :let={{_id, document}} label="Title">{document.title}</:col>
          <:action :let={{_id, document}}>
            <div class="sr-only">
              <.link navigate={~p"/workspace/documents/#{document}"}>Show</.link>
            </div>
            <.link navigate={~p"/workspace/documents/#{document}/edit"}>Edit</.link>
          </:action>
          <:action :let={{_id, document}}>
            <.link
              phx-click={JS.push("delete", value: %{id: document.id})}
              data-confirm={gettext("Do you really want to delete this document?")}
            >
              {gettext("Delete")}
            </.link>
          </:action>
        </.table>
      </Layouts.app>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Workspace.subscribe_documents(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Documents")
     |> stream(:documents, list_documents(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document = Workspace.get_document!(socket.assigns.current_scope, id)
    {:ok, _} = Workspace.delete_document(socket.assigns.current_scope, document)

    {:noreply, stream_delete(socket, :documents, document)}
  end

  @impl true
  def handle_info({type, %TeacherCoop.Workspace.Document{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :documents, list_documents(socket.assigns.current_scope), reset: true)}
  end

  defp list_documents(current_scope) do
    Workspace.list_documents(current_scope)
  end
end

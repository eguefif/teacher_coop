defmodule TeacherCoopWeb.DocumentLive.Index do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Library

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("My Documents")}
        <:actions>
          <.button variant="primary" navigate={~p"/documents/new"}>
            <.icon name="hero-plus" /> {gettext("New")} {gettext("Document")}
          </.button>
        </:actions>
      </.header>

      <.table
        id="documents"
        rows={@streams.documents}
        row_click={fn {_id, document} -> JS.navigate(~p"/documents/#{document}") end}
      >
        <:col :let={{_id, document}} label={gettext("titre") |> String.capitalize()}>
          {document.title}
        </:col>
        <:col :let={{_id, document}} label={gettext("description") |> String.capitalize()}>
          {document.description}
        </:col>
        <:col :let={{_id, document}} label={gettext("institution type") |> String.capitalize()}>
          {document.description}
        </:col>
        <:action :let={{_id, document}}>
          <div class="sr-only">
            <.link navigate={~p"/documents/#{document}"}>Show</.link>
          </div>
          <.link navigate={~p"/documents/#{document}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, document}}>
          <.link
            phx-click={JS.push("delete", value: %{id: document.id}) |> hide("##{id}")}
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
    if connected?(socket) do
      Library.subscribe_documents(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Documents")
     |> stream(:documents, list_documents(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document = Library.get_document!(id)
    {:ok, _} = Library.delete_document(socket.assigns.current_scope, document)

    {:noreply, stream_delete(socket, :documents, document)}
  end

  @impl true
  def handle_info({type, %TeacherCoop.Library.Document{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :documents, list_documents(socket.assigns.current_scope), reset: true)}
  end

  defp list_documents(current_scope) do
    Library.list_documents(current_scope)
  end
end

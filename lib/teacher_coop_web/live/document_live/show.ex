defmodule TeacherCoopWeb.DocumentLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Library

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Document {@document.id}
        <:subtitle>This is a document record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/documents"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/documents/#{@document}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit document
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@document.title}</:item>
        <:item title="Description">{@document.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Library.subscribe_documents(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Document")
     |> assign(:document, Library.get_document!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %TeacherCoop.Library.Document{id: id} = document},
        %{assigns: %{document: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :document, document)}
  end

  def handle_info(
        {:deleted, %TeacherCoop.Library.Document{id: id}},
        %{assigns: %{document: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current document was deleted.")
     |> push_navigate(to: ~p"/documents")}
  end

  def handle_info({type, %TeacherCoop.Library.Document{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end

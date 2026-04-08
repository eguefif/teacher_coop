defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@document.title}
        <:actions>
          <.button navigate={~p"/workspace/documents"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/workspace/documents/#{@document}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit document
          </.button>
        </:actions>
      </.header>

      <div>
        {@document.description}
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Workspace.subscribe_documents(socket.assigns.current_scope)
    end

    document = Workspace.get_document!(socket.assigns.current_scope, id)

    {:ok,
     socket
     |> assign(:page_title, "Show Document")
     |> assign(:document, document)
     |> assign(:files, Workspace.get_files(document.id))}
  end

  @impl true
  def handle_info(
        {:updated, %TeacherCoop.Workspace.Document{id: id} = document},
        %{assigns: %{document: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :document, document)}
  end

  def handle_info(
        {:deleted, %TeacherCoop.Workspace.Document{id: id}},
        %{assigns: %{document: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current document was deleted.")
     |> push_navigate(to: ~p"/workspace/documents")}
  end

  def handle_info({type, %TeacherCoop.Workspace.Document{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end

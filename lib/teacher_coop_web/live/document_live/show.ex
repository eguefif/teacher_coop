defmodule TeacherCoopWeb.DocumentLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Library

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Document")} {@document.id}
        <:actions>
          <.button navigate={@return_to}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            :if={@current_scope != nil && @current_scope.user.id == @document.user_id}
            variant="primary"
            navigate={~p"/documents/#{@document}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> {gettext("Edit")} {gettext("document")}
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title={gettext("title") |> String.capitalize()}>{@document.title}</:item>
        <:item title={gettext("description") |> String.capitalize()}>{@document.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id, "return_to" => "search"}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Document")
     |> assign(:document, Library.get_document!(id))
     |> assign(:return_to, ~p"/search")}
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Document")
     |> assign(:document, Library.get_document!(id))
     |> assign(:return_to, ~p"/documents")}
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

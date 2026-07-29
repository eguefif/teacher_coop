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

      <div class="flex flex-wrap flex-row gap-8 justify-start w-[740px] mx-auto">
        <div
          :for={{id, document} <- @streams.documents}
          id={id}
          class="card card-xs shadow-sm w-[224px] bg-base-200 p-4 scale-100 hover:scale-101 transition-transform duration-100 ease-in-out relative"
        >
          <a
            class="btn btn-neutral btn-circle absolute -top-2 -right-2"
            phx-click="delete"
            phx-value-id={document.id}
          ><.icon name="hero-x-mark" /></a>
          <div
            class="card-body hover:cursor-pointer"
            phx-click={JS.navigate(~p"/documents/#{document}")}
          >
            <div class="card-title">{document.title}</div>
            <div>{document.description}</div>
          </div>
          <div class="card-actions justify-end">
            <.button variant="soft" navigate={~p"/documents/#{document}/edit"}>{gettext("Edit")}</.button>
          </div>
        </div>
      </div>
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

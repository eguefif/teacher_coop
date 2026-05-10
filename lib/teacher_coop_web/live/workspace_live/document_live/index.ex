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
            <.button navigate={~p"/workspace/"}><.icon name="hero-arrow-left" /></.button>
            <.button variant="primary" navigate={~p"/workspace/documents/new"}>
              <.icon name="hero-plus" /> {gettext("New Document")}
            </.button>
            <%= if @document_layout == :list do %>
              <.button type="button" phx-click="toggle-layout">
                <span class="hero-squares-2x2" />
              </.button>
            <% else %>
              <.button type="button" phx-click="toggle-layout">
                <span class="hero-list-bullet" />
              </.button>
            <% end %>
          </:actions>
        </.header>
        <%= if @document_layout == :grid do %>
          <.documents_grid_view documents={@documents} />
        <% else %>
          <.documents_list_view documents={@documents} />
        <% end %>
      </Layouts.app>
    <% end %>
    """
  end

  attr :documents, :list, required: true

  def documents_list_view(assigns) do
    ~H"""
    <div class="list">
      <div
        :for={document <- @documents}
        class="list-row"
      >
        <.link class="list-col-grow" navigate={~p"/workspace/documents/#{document}"}>
          {document.title}
        </.link>
        <div class="flex flex-row gap-4 ml-auto">
          <.link
            phx-click={JS.push("delete", value: %{id: document.id})}
            data-confirm={gettext("Do you really want to delete this document")}
          >
            {gettext("Delete")}
          </.link>
          <.link navigate={~p"/workspace/documents/#{document}/edit?return_to=index"}>
            {gettext("Edit")}
          </.link>
        </div>
      </div>
    </div>
    """
  end

  attr :documents, :list, default: []

  def documents_grid_view(assigns) do
    ~H"""
    <div class="flex flex-row flex-wrap gap-4">
      <div
        :for={document <- @documents}
        id={"document-" <> Integer.to_string(document.id)}
        class="card w-52 bg-base-100 card-xs shadow-sm 
        scale-100 hover:scale-105 transition-transform duration-150"
      >
        <div class="card-body">
          <div class="card-actions justify-end">
            <.button
              class="btn btn-circle btn-xs"
              navigate={~p"/workspace/documents/#{document}/edit?return_to=index"}
            >
              <div class="hero-pencil size-4" />
            </.button>
            <.button
              class="btn btn-circle btn-xs"
              phx-click={JS.push("delete", value: %{id: document.id})}
              data-confirm={gettext("Do you really want to delete this document")}
            >
              <div class="hero-x-mark" />
            </.button>
          </div>

          <.link navigate={~p"/workspace/documents/#{document}"}>
            <div class="card-title">
              {document.title}
            </div>
            <p>
              {document.description}
            </p>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Listing Documents"))
     |> assign(:document_layout, :list)
     |> assign(:documents, list_documents(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document = Workspace.get_document!(socket.assigns.current_scope, id)
    {:ok, _} = Workspace.delete_document(socket.assigns.current_scope, document)

    {:noreply, stream_delete(socket, :documents, document)}
  end

  @impl true
  def handle_event("toggle-layout", %{}, socket) do
    case socket.assigns.document_layout do
      :grid -> {:noreply, socket |> assign(:document_layout, :list)}
      :list -> {:noreply, socket |> assign(:document_layout, :grid)}
    end
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

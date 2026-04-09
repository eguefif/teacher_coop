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

      <div class="flex flex-col gap-8">
        <div>
          {@document.description}
        </div>

        <div class="flex flex-row gap-4">
          <article
            :for={tag <- TeacherCoop.Tags.get_tags_from_indexes(String.split(@document.tags || "", " ", trim: true))}
            class="badge badge-soft badge-lg badge-primary"
          >
            {tag}
          </article>
        </div>

        <section>
          <h2>{gettext("Files")}</h2>
          <.table
            id="files"
            rows={@files}
          >
            <:col :let={file} label={gettext("Filename")}>{file.filename}</:col>
            <:action :let={file}>
              <.link
                phx-click={JS.push("delete", value: %{id: file.id})}
                data-confirm={gettext("Do you really want to delete this file?")}
              >
                {gettext("Delete")}
              </.link>
            </:action>
          </.table>
        </section>
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

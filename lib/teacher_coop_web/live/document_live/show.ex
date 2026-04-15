defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@document.title}
        <div :if={@document.tags != []} class="flex flex-row gap-4">
          <article
            :for={tag <- @document.tags}
            class="badge badge-soft badge-lg badge-primary"
          >
            {tag}
          </article>
        </div>
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

      <div :if={@document.goals != []} class="flex flex-col gap-4">
        <h2>{gettext("Goals")}</h2>
        <ul class="list-disc list-inside">
          <li :for={entry <- @document.goals} class="ml-2">{entry}</li>
        </ul>
      </div>

      <div class="flex flex-col gap-8">
        <h2>{gettext("Description")}</h2>
        <div>
          {@document.description}
        </div>

        <section :if={@files != []}>
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

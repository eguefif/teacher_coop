defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace
  alias TeacherCoop.Workspace.Groups

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col gap-8">
        <.show_header document={@document} />

        <.show_document
          goals={@document.goals}
          description={@document.description}
          tags={@document.tags}
        />

        <.show_files files={@files} />

        <div class="divider"></div>
        <.show_groups_sharing document_id={@document.id} groups={@groups} />
      </div>
    </Layouts.app>
    """
  end

  attr :document, :map, required: true

  def show_header(assigns) do
    ~H"""
    <.header return={~p"/workspace/documents/"}>
      {@document.title}
      <:actions>
        <.button phx-click="toggle-public" phx-value-id={@document.id}>
          {if @document.public, do: gettext("Make Private"), else: gettext("Make Public")}
        </.button>
        <.button navigate={~p"/workspace/documents/#{@document}/edit?return_to=show"}>
          <.icon name="hero-pencil-square" />
        </.button>
      </:actions>
    </.header>
    """
  end

  attr :goals, :list, default: []
  attr :description, :string, default: ""
  attr :tags, :list, required: true

  def show_document(assigns) do
    ~H"""
    <div :if={@goals != []} class="flex flex-col gap-4 rounded-box shadow-md">
      <ul class="list list-inside">
        <li class="p-2 pb-4 text-m opacity-80 tracking-wide">{gettext("Document goals")}</li>
        <li :for={{entry, idx} <- Enum.with_index(@goals)} class="list-row ml-2">
          <div class="text-4xl font-thin tabular-nums">{idx + 1}</div>
          <div class="list-col-grow">{entry}</div>
        </li>
      </ul>
    </div>

    <div class="flex flex-row justify-center">
      <div :if={@tags != []} class="flex flex-row gap-4">
        <article
          :for={tag <- @tags}
          class="badge badge-soft badge-lg badge-primary"
        >
          {tag}
        </article>
      </div>
    </div>

    <div class="flex flex-col gap-8">
      <h1 class="text-xl font-bold">{gettext("Description")}</h1>
      <div class="indent-2">
        {@description}
      </div>
    </div>
    """
  end

  attr :files, :list, default: []

  def show_files(assigns) do
    ~H"""
    <section :if={@files != []}>
      <h1 class="text-xl font-bold">{gettext("Files")}</h1>
      <.table
        id="files"
        rows={@files}
      >
        <:col :let={file}>{file.filename}</:col>
        <:action :let={file}>
          <.link navigate={~p"/workspace/file/#{file}/download"}>{gettext("Download")}</.link>
          <.link
            phx-click={JS.push("delete", value: %{id: file.id})}
            data-confirm={gettext("Do you really want to delete this file?")}
          >
            {gettext("Delete")}
          </.link>
        </:action>
      </.table>
    </section>
    """
  end

  attr :document_id, :string, required: true
  attr :groups, :list, default: []

  def show_groups_sharing(assigns) do
    ~H"""
    <section>
      <h1 class="text-xl font-bold">{gettext("Groups")}</h1>
      <.table
        id="groups"
        rows={@groups}
      >
        <:col :let={group}>{group.name}</:col>
        <:action :let={group}>
          <.link
            :if={!group.shared}
            phx-click={
              JS.push("share-document", value: %{document_id: @document_id, group_id: group.id})
            }
          >
            {gettext("Share")}
          </.link>
          <.link
            :if={group.shared}
            phx-click={
              JS.push("unshare-document", value: %{document_id: @document_id, group_id: group.id})
            }
          >
            <!-- TODO: Check policy: only the owner of the document should be able to unshare -->
            {gettext("Unshare")}
          </.link>
        </:action>
      </.table>
    </section>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    id = params["id"]
    document = Workspace.get_document!(socket.assigns.current_scope, id)
    groups = Groups.get_document_groups(socket.assigns.current_scope, id)

    {:ok,
     socket
     |> assign(:page_title, "Show Document")
     |> assign(:document, document)
     |> assign(:groups, groups)
     |> assign(:files, Workspace.get_files(document.id))}
  end

  @impl true
  def handle_event(
        "share-document",
        %{"document_id" => document_id, "group_id" => group_id},
        socket
      ) do
    Groups.share_document(socket.assigns.current_scope, group_id, document_id)
    groups = Groups.get_document_groups(socket.assigns.current_scope, document_id)
    {:noreply, socket |> assign(:groups, groups)}
  end

  @impl true
  def handle_event(
        "unshare-document",
        %{"document_id" => document_id, "group_id" => group_id},
        socket
      ) do
    Groups.unshare_document(socket.assigns.current_scope, group_id, document_id)
    groups = Groups.get_document_groups(socket.assigns.current_scope, document_id)
    {:noreply, socket |> assign(:groups, groups)}
  end

  @impl true
  def handle_event("toggle-public", %{"id" => id}, socket) do
    document =
      Workspace.update_public(socket.assigns.current_scope, id, !socket.assigns.document.public)

    {:noreply, socket |> assign(:document, document)}
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

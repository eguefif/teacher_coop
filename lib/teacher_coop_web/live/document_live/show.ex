defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace
  alias TeacherCoop.Groups

  # TODO: Returns should return to group when coming from group.

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.show_header document={@document} />

      <.show_document goals={@document.goals} description={@document.description} />

      <.show_files files={@files} />

      <.show_groups_sharing document_id={@document.id} groups={@groups} />
    </Layouts.app>
    """
  end

  attr :document, :map

  def show_header(assigns) do
    ~H"""
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
        <.button onclick="history.back(); return false;">
          <.icon name="hero-arrow-left" />
        </.button>
        <.button variant="primary" phx-click="toggle-public" phx-value-id={@document.id}>
          {if @document.public, do: gettext("Make Private"), else: gettext("Make Public")}
        </.button>
        <.button
          variant="primary"
          navigate={~p"/workspace/documents/#{@document}/edit?return_to=show"}
        >
          <.icon name="hero-pencil-square" /> {gettext("Edit document")}
        </.button>
      </:actions>
    </.header>
    """
  end

  attr :goals, :list, default: []
  attr :description, :string, default: ""

  def show_document(assigns) do
    ~H"""
    <div :if={@goals != []} class="flex flex-col gap-4">
      <h2>{gettext("Goals")}</h2>
      <ul class="list-disc list-inside">
        <li :for={entry <- @goals} class="ml-2">{entry}</li>
      </ul>
    </div>

    <div class="flex flex-col gap-8">
      <h2>{gettext("Description")}</h2>
      <div>
        {@description}
      </div>
    </div>
    """
  end

  attr :files, :list, default: []

  def show_files(assigns) do
    ~H"""
    <section :if={@files != []}>
      <h2>{gettext("Files")}</h2>
      <.table
        id="files"
        rows={@files}
      >
        <:col :let={file} label={gettext("Filename")}>{file.filename}</:col>
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
      <h2>{gettext("Groups")}</h2>
      <.table
        id="groups"
        rows={@groups}
      >
        <:col :let={group} label={gettext("Working Group")}>{group.name}</:col>
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
            {gettext("Unshare")}
          </.link>
        </:action>
      </.table>
    </section>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      Workspace.subscribe_documents(socket.assigns.current_scope)
    end

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

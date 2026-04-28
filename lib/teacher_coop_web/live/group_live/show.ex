defmodule TeacherCoopWeb.WorkspaceLive.GroupLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Groups
  alias TeacherCoop.Accounts
  alias TeacherCoopWeb.Reusables

  # TODO: Add download

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@group.name}
        <:actions>
          <.button navigate={~p"/workspace/groups"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/workspace/groups/#{@group}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> {gettext("Edit Group")}
          </.button>
        </:actions>
      </.header>
      <.invite_connection :if={@is_admin} autocomplete={@autocomplete} />
      <.members_list members={@members} current_scope={@current_scope} is_admin={@is_admin} />
      <.documents_list documents={@documents} />
    </Layouts.app>
    """
  end

  attr :autocomplete, :list, default: []

  def invite_connection(assigns) do
    ~H"""
    <section>
      <.live_component
        module={Reusables.AutocompleteInput}
        id="group-members-search"
        name="group-members-search"
        autocomplete_list={@autocomplete}
        on_user_typing={fn value -> send(self(), {:user_typing, value}) end}
        on_autocomplete_submit={fn value -> send(self(), {:user_submit, value}) end}
      />
    </section>
    """
  end

  attr :members, :list, default: []
  attr :current_scope, :map, required: true
  attr :is_admin, :boolean, default: false

  def members_list(assigns) do
    ~H"""
    <section class="mt-6">
      <h2 class="text-lg font-semibold mb-4">{gettext("Members")}</h2>
      <.table id="members" rows={@members}>
        <:col :let={member} label={gettext("Name")}>{member.fullname}</:col>
        <:col :let={member} label={gettext("Email")}>{member.email}</:col>
        <:col :let={member} label={gettext("Role")}>
          <span class={["badge badge-soft badge-sm", badge_class(member.role)]}>
            {member.role}
          </span>
        </:col>
        <:action :let={member} :if={@is_admin}>
          <.link
            :if={member.user_id != @current_scope.user.id}
            phx-click={JS.push("remove-member", value: %{membership_id: member.membership_id})}
            data-confirm={gettext("Are you sure?")}
          >
            {gettext("Remove")}
          </.link>
        </:action>
      </.table>
    </section>
    """
  end

  attr :documents, :list, default: []

  def documents_list(assigns) do
    ~H"""
    <section :if={@documents != []}>
      <h2 class="text-lg font-semibold mb-4">{gettext("Documents")}</h2>
      <.table id="documents" rows={@documents}>
        <:col :let={document} label={gettext("Document Name")}>{document.title}</:col>
        <:action :let={document}>
          <.link navigate={~p"/workspace/documents/#{document}"}>{gettext("show")}</.link>
        </:action>
      </.table>
    </section>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    group = Groups.get_group_for_member!(socket.assigns.current_scope, id)
    members = Groups.list_members(group.id)
    is_admin = Groups.is_admin?(socket.assigns.current_scope, group.id)
    documents = Groups.get_shared_documents(group.id)

    {:ok,
     socket
     |> assign(:page_title, group.name)
     |> assign(:group, group)
     |> assign(:is_admin, is_admin)
     |> assign(:members, members)
     |> assign(:autocomplete, [])
     |> assign(:documents, documents)}
  end

  defp badge_class("admin"), do: "badge-primary"
  defp badge_class(_), do: "badge-secondary"

  # Handle Event *********************************
  @impl true
  def handle_event("remove-member", %{"membership_id" => member_id}, socket) do
    Groups.remove_membership_by_id(socket.assigns.current_scope, member_id)
    members = Groups.list_members(socket.assigns.group.id)
    {:noreply, socket |> assign(:members, members)}
  end

  # Handle Info ********************************
  @impl true
  def handle_info({:user_submit, value}, socket) do
    # TODO: Handle error
    Groups.invite_user_to_group(
      socket.assigns.current_scope,
      socket.assigns.group.id,
      value.id
    )

    members = Groups.list_members(socket.assigns.group.id)

    {:noreply, socket |> assign(:members, members)}
  end

  @impl true
  def handle_info({:user_typing, user_input}, socket) do
    IO.puts("In handle info: " <> user_input)

    results =
      Accounts.search_user_in_current_user_connections(socket.assigns.current_scope, user_input)
      |> Enum.map(fn entry -> %{id: entry.id, value: entry.fullname} end)

    {:noreply, socket |> assign(:autocomplete, results)}
  end
end

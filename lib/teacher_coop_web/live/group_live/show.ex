defmodule TeacherCoopWeb.WorkspaceLive.GroupLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Groups
  alias TeacherCoop.Accounts
  alias TeacherCoopWeb.Reusables

  # TODO:
  # - [ ] Add colleague: just add people easily and fast that are in your graph

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
      <.invite_colleague autocomplete={@autocomplete} />
      <.members_list members={@members} />
    </Layouts.app>
    """
  end

  attr :autocomplete, :list, default: []

  def invite_colleague(assigns) do
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
      </.table>
    </section>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    group = Groups.get_group_for_member!(socket.assigns.current_scope, id)
    members = Groups.list_members(group.id)

    {:ok,
     socket
     |> assign(:page_title, group.name)
     |> assign(:group, group)
     |> assign(:members, members)
     |> assign(:autocomplete, [])}
  end

  defp badge_class("admin"), do: "badge-primary"
  defp badge_class(_), do: "badge-secondary"

  # Handle Info ********************************
  @impl true
  def handle_info({:user_submit, _value}, socket) do
    {:noreply, socket}
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

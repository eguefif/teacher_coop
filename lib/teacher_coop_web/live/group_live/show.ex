defmodule TeacherCoopWeb.WorkspaceLive.GroupLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Groups

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
    </Layouts.app>
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
     |> assign(:members, members)}
  end

  defp badge_class("admin"), do: "badge-primary"
  defp badge_class(_), do: "badge-secondary"
end

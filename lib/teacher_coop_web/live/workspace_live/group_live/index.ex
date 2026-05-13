defmodule TeacherCoopWeb.WorkspaceLive.GroupLive.Index do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Workspace.Groups

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header return={~p"/workspace/"}>
        {gettext("My Groups")}
        <:actions>
          <.button variant="primary" navigate={~p"/workspace/groups/new"}>
            <.icon name="hero-plus" /> {gettext("New Group")}
          </.button>
        </:actions>
      </.header>
      <ul :if={@groups != []} class="list box-rounded shadow-md">
        <li
          :for={group <- @groups}
          class="list-row"
        >
          <.link navigate={~p"/workspace/groups/#{group.id}"}>
            <div class="font-bold">
              {group.name}
            </div>
            <div class="text-clamp-2">Description</div>
          </.link>
        </li>
      </ul>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    groups = Groups.get_user_groups(socket.assigns.current_scope)
    {:ok, assign(socket, :groups, groups)}
  end
end

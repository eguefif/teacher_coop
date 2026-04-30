defmodule TeacherCoopWeb.WorkspaceLive.GroupLive.Index do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Workspace.Groups

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("My Groups")}
        <:actions>
          <.button navigate={~p"/workspace/"}><.icon name="hero-arrow-left" /></.button>
          <.button variant="primary" navigate={~p"/workspace/groups/new"}>
            <.icon name="hero-plus" /> {gettext("New Group")}
          </.button>
        </:actions>
      </.header>
      <div :if={@groups != []} class="flex flex-row gap-4 justify-around flex-wrap">
        <.button
          :for={group <- @groups}
          navigate={~p"/workspace/groups/#{group.id}"}
          class="p-4 border-2 rounded-md hover:scale-105 hover:shadow-lg cursor-pointer"
        >
          {group.name}
        </.button>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    groups = Groups.get_user_groups(socket.assigns.current_scope)
    {:ok, assign(socket, :groups, groups)}
  end
end

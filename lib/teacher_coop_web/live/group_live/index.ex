defmodule TeacherCoopWeb.WorkspaceLive.GroupLive.Index do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Groups

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("My Groups")}
      </.header>
      <div :if={@groups != []} class="flex flex-row gap-4 justify-between flex-wrap">
        <div
          :for={group <- @groups}
          class="p-4 border-2 rounded-md hover:scale-105 hover:shadow-lg cursor-pointer"
        >
          {group.name}
        </div>
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

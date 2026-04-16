defmodule TeacherCoopWeb.WorkspaceLive.GroupLive.Index do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Groups

  # TODO:
  # - [ ] Add button to add groups
  # - [ ] Add link and show group page and route
  # - [ ] Add a search for group

  # TODO: 
  # - [ ] Show group
  #   - [ ] Add member using a search
  #   - [ ] list member and add a button to promote admin or demote

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @live_action in [:new, :edit] do %>
      <.live_component
        module={WorkspaceLive.GroupLive.FormComponent}
        id={@group || :new}
        action={@live_action}
        current_scope={@current_scope}
      />
    <% else %>
      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <.header>
          {gettext("My Groups")}
          <:actions>
            <.button variant="primary" navigate={~p"/workspace/groups/new"}>
              <.icon name="hero-plus" /> {gettext("New Group")}
            </.button>
          </:actions>
        </.header>
        <div :if={@groups != []} class="flex flex-row gap-4 justify-between flex-wrap">
          <div
            :for={group <- @groups}
            class="p-4 border-2 rounded-md hover:scale-105 hover:shadow-lg cursor-pointer"
          >
            <.button navigate={~p"/workspace/groups/#{group.id}"} class="">
              {group.name}
            </.button>
          </div>
        </div>
      </Layouts.app>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    groups = Groups.get_user_groups(socket.assigns.current_scope)
    {:ok, assign(socket, :groups, groups)}
  end
end

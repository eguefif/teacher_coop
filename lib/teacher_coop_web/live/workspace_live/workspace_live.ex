defmodule TeacherCoopWeb.WorkspaceLive.Workspace do
  use TeacherCoopWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-row gap-8 justify-between">
        <div class="mx-auto">
          <.button navigate={~p"/workspace/documents"}>{gettext("My Documents")}</.button>
        </div>
        <div class="mx-auto">
          <.button navigate={~p"/workspace/groups"}>{gettext("My Groups")}</.button>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

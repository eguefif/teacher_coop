defmodule TeacherCoopWeb.WorkspaceLive.ColleagueLive.Index do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.TeacherNetworking

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("My Colleagues")}
        <:actions>
          <.button navigate={~p"/workspace/"}><.icon name="hero-arrow-left" /></.button>
        </:actions>
      </.header>
      <ul class="list">
        <li :for={colleague <- @colleagues} class="list-row">{colleague.fullname}</li>
      </ul>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _sessions, socket) do
    colleagues = TeacherNetworking.get_connections(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:colleagues, colleagues)}
  end
end

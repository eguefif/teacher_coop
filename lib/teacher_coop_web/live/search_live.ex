defmodule TeacherCoopWeb.SearchLive do
  use TeacherCoopWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(form: to_form(%{}, as: :search))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div>
        <.form
          for={@form}
          id="search_form"
          phx-submit="search"
          phx-change="validate"
          class="flex flex-col items-center gap-12"
        >
          <.input field={@form[:search]} type="search" />
          <.button>{gettext("Submit")}</.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end
end

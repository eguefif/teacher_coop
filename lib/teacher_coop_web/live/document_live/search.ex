defmodule TeacherCoopWeb.DocumentLive.Search do
  use TeacherCoopWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex-col gap-16">
        <.input name="search" type="text" value="" placeholder="Un petit prince..." />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope =
      if Map.has_key?(socket.assigns, :current_scope), do: socket.assigns.current_scope, else: nil

    {:ok, socket |> assign_new(:current_scope, fn -> scope end)}
  end
end

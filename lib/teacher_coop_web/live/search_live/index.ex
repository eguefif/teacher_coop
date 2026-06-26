defmodule TeacherCoopWeb.SearchLive.Index do
  use TeacherCoopWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Searches
        <:actions>
          <.button variant="primary" navigate={~p"/searches/new"}>
            <.icon name="hero-plus" /> New Search
          </.button>
        </:actions>
      </.header>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Searches")}
  end
end

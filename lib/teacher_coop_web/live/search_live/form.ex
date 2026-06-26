defmodule TeacherCoopWeb.SearchLive.Form do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Discovery

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <form
        phx-change="update-search"
        phx-submit="trigger-search"
        class="flex flex-col gap-4 items-center"
      >
        <.input
          id="search"
          name="search"
          type="text"
          value={@search_terms}
          placeholder="Un petit prince..."
          class="input w-150 h-14 rounded-4xl"
        />
        <div>
          <.button
            name="trigger-search"
            class="btn btn-primary btn-soft btn-lg rounded-xl"
            phx-click="trigger-search"
          >
            Search
          </.button>
        </div>
      </form>
      <div :if={@results != :none}>
        <ul :for={result <- @results} class="list">
          <li class="list-row">
            <div class="flex flex-col gap-2 m-4 p-4 rounded-box shadow-md">
              <div class="text-lg">{result["title"]}</div>
              <div>{result["description"]}</div>
            </div>
          </li>
        </ul>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope =
      if Map.has_key?(socket.assigns, :current_scope), do: socket.assigns.current_scope, else: nil

    {:ok,
     socket
     |> assign_new(:current_scope, fn -> scope end)
     |> assign(:search_terms, "")
     |> assign(:results, :none)}
  end

  @impl true
  def handle_event("trigger-search", %{}, socket) do
    {:ok, results} =
      Discovery.create_search(socket.assigns.current_scope, %{
        search_terms: socket.assigns.search_terms
      })

    {:noreply,
     socket
     |> assign(:results, results.hits)
     |> assign(:search_terms, socket.assigns.search_terms)}
  end

  @impl true
  def handle_event("update-search", %{"search" => search_terms}, socket) do
    {:noreply,
     socket |> assign(:search_terms, search_terms) |> assign(:results, socket.assigns.results)}
  end
end

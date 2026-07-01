defmodule TeacherCoopWeb.SearchLive.Search do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Discovery
  alias TeacherCoopWeb.Date

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col items-center">
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
              {gettext("Search")}
            </.button>
          </div>
        </form>
        <div :if={@results != nil} class="max-w-200">
          <ul :for={result <- @results} class="list w-200">
            <li class="list-row mb-4">
              <div class="flex flex-col gap-4">
                <div class="flex flex-row gap-4 items-baseline">
                  <div class="text-lg">
                    <.link
                      class="btn-ghost"
                      navigate={~p"/documents/#{result["id"]}?return_to=search"}
                    >
                      {result["title"]}
                    </.link>
                  </div>
                  - <span class="">{result["inserted_at"] |> Date.format_time()}</span>
                </div>
                <div class="text-xs font-semibold uppercase">{result["institution_type"]}</div>
                <div class="text-base text-justify">{result["description"]}</div>
              </div>
            </li>
          </ul>
        </div>
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
     |> assign(:results, nil)}
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

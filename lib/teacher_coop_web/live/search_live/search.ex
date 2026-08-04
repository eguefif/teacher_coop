defmodule TeacherCoopWeb.SearchLive.Search do
  use TeacherCoopWeb, :live_view
  alias TeacherCoop.Discovery

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col items-center gap-[64px]">
        <form
          phx-change="update-search"
          phx-submit="trigger-search"
          class="flex flex-row gap-[48px] items-baseline"
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
        <div :if={@results != nil} class="max-w-200 flex flex-col gap-[64px]">
          <div :for={result <- @results} class="w-200">
            <.result result={result} />
          </div>
        </div>
      </div>
      <pre><%= inspect @results, pretty: true %></pre>
    </Layouts.app>
    """
  end

  attr :result, :map

  def result(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div class="flex flex-row gap-4 items-baseline">
        <div class="text-lg">
          <.link
            class="btn-ghost hover:underline"
            navigate={~p"/documents/#{@result["id"]}?return_to=search"}
          >
            <div class="text-primary text-xl">{@result["title"]}</div>
          </.link>
        </div>
      </div>
      <div class="text-md font-semibold uppercase opacity-60">
        {@result["institution_type"]} - {@result["grade"]}
      </div>
      <div class="text-base text-justify">{@result["description"]}</div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope =
      if Map.has_key?(socket.assigns, :current_scope), do: socket.assigns.current_scope, else: nil

    {:ok, results} =
      Discovery.create_search(scope, %{
        search_terms: "fraction"
      })

    {:ok,
     socket
     |> assign_new(:current_scope, fn -> scope end)
     |> assign(:search_terms, "fraction")
     |> assign(:results, results.hits)}
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

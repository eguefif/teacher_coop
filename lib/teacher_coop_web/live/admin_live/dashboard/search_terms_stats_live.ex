defmodule TeacherCoopWeb.AdminLive.SearchTermsStatsLive do
  use TeacherCoopWeb, :live_component

  alias TeacherCoop.Dashboard

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div class="flex flex-row gap-4 justify-around">
        <.async_result
          :let={top_search_terms_with_no_result}
          assign={@top_search_terms_with_no_result}
        >
          <:loading><div class="skeleton" /></:loading>
          <:failed>{gettext("Failed to retrieve data")}</:failed>
          <.stat_grid
            title={gettext("Popular words with no result")}
            data={top_search_terms_with_no_result}
          />
        </.async_result>
        <.async_result
          :let={popular_search_terms}
          assign={@popular_search_terms}
        >
          <:loading><div class="skeleton" /></:loading>
          <:failed>{gettext("Failed to retrieve data")}</:failed>
          <.stat_grid
            title={gettext("Popular search terms")}
            data={popular_search_terms}
          />
        </.async_result>
      </div>
    </div>
    """
  end

  attr :data, :map
  attr :title, :string

  def stat_grid(assigns) do
    ~H"""
    <div class="flex flex-col gap-[32px]">
      <div class="text-2xl">{@title}</div>
      <div class="overflow-x-auto">
        <table class="table">
          <thead>
            <tr>
              <th>{gettext("Popular words")}</th>
              <th>{gettext("Frequency")}</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={row <- @data}>
              <th>{row.word}</th>
              <th>{row.frequency}</th>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @impl true
  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign(:click_position_id, "graph-click-position")
     |> assign_async(:top_search_terms_with_no_result, fn ->
       {:ok,
        %{
          top_search_terms_with_no_result: Dashboard.WordStats.top_search_terms_with_no_result()
        }}
     end)
     |> assign_async(:popular_search_terms, fn ->
       {:ok,
        %{
          popular_search_terms: Dashboard.WordStats.top_search_terms()
        }}
     end)}
  end
end

defmodule TeacherCoopWeb.AdminLive.SearchTermsStatsLive do
  use TeacherCoopWeb, :live_component

  alias TeacherCoop.Dashboard

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div class="flex flex-row gap-4 justify-around">
        <.async_result :let={click_position_data} assign={@click_position_data}>
          <:loading><div class="skeleton" /></:loading>
          <:failed>{gettext("Failed to retrieve data")}</:failed>
          <.live_component
            module={TeacherCoopWeb.AdminLive.BarGraph}
            title={gettext("Zero results by Search terms")}
            data={click_position_data}
            orient={:horizontal}
            id={@click_position_id}
          />
        </.async_result>
      </div>
    </div>
    """
  end

  @impl true
  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign(:click_position_id, "graph-click-position")
     |> assign_async(:click_position_data, fn ->
       {:ok,
        %{
          click_position_data:
            Dashboard.zero_results_by_search_terms(7)
            |> Enum.sort(&(&1 >= &2))
            |> Enum.map(fn elem ->
              %{x: elem.position, y: elem.count}
            end)
        }}
     end)}
  end
end

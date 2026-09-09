defmodule TeacherCoopWeb.AdminLive.SearchGraphsLive do
  use TeacherCoopWeb, :live_component

  alias TeacherCoop.Dashboard

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div class="flex flex-row gap-4 justify-around">
        <.async_result :let={searches_count_data} assign={@searches_count_data}>
          <:loading><div class="skeleton" /></:loading>
          <:failed>{gettext("Failed to retrieve data")}</:failed>
          <.live_component
            module={TeacherCoopWeb.AdminLive.Graph}
            title={gettext("Search counts")}
            data={searches_count_data}
            id={@searches_count_id}
          />
        </.async_result>
      </div>
      <div class="flex flex-row gap-4 justify-around">
        <.async_result :let={zero_results_data} assign={@zero_results_data}>
          <:loading><div class="skeleton" /></:loading>
          <:failed>{gettext("Failed to retrieve data")}</:failed>
          <.live_component
            module={TeacherCoopWeb.AdminLive.Graph}
            title={gettext("Zero results")}
            data={zero_results_data}
            id={@graph_zero_result_id}
          />
        </.async_result>
        <.async_result :let={failed_results_data} assign={@failed_results_data}>
          <:loading><div class="skeleton" /></:loading>
          <:failed>{gettext("Failed to retrieve data")}</:failed>
          <.live_component
            module={TeacherCoopWeb.AdminLive.Graph}
            title={gettext("Failed results")}
            data={failed_results_data}
            id={@graph_failed_result_id}
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
     |> assign(:graph_zero_result_id, "graph-zero-result")
     |> assign(:graph_failed_result_id, "graph-failed-result")
     |> assign(:searches_count_id, "graph-search-count")
     |> assign_async(:zero_results_data, fn ->
       {:ok,
        %{
          zero_results_data:
            Dashboard.zero_results(7)
            |> Enum.map(fn elem ->
              %{x: elem.date, y: elem.count}
            end)
        }}
     end)
     |> assign_async(:failed_results_data, fn ->
       {:ok,
        %{
          failed_results_data:
            Dashboard.failed_results(7)
            |> Enum.map(fn elem ->
              %{x: elem.date, y: elem.count}
            end)
        }}
     end)
     |> assign_async(:searches_count_data, fn ->
       {:ok,
        %{
          searches_count_data:
            Dashboard.searches_count(7)
            |> Enum.map(fn elem ->
              %{x: elem.date, y: elem.count}
            end)
        }}
     end)}
  end
end

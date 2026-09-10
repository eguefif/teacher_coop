defmodule TeacherCoopWeb.AdminLive.DashboardLive do
  use TeacherCoopWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {gettext("Dashboard")}
      </.header>
      <div class="flex flex-col gap-8">
        <.live_component
          module={TeacherCoopWeb.AdminLive.DocumentsCountLive}
          id={@documents_count_component_id}
          current_scope={@current_scope}
        />
        <div class="divider"></div>
        <.live_component
          module={TeacherCoopWeb.AdminLive.SearchGraphsLive}
          id={@search_graphs_id}
        />
        <div class="divider"></div>
        <.live_component
          module={TeacherCoopWeb.AdminLive.SearchTermsStatsLive}
          id={@search_terms_stats_id}
        />
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:documents_count_component_id, "documents-count")
     |> assign(:search_terms_stats_id, "search-terms-stats-id")
     |> assign(:search_graphs_id, "search-graphs")}
  end
end

defmodule TeacherCoopWeb.AdminLive.CurriculumLive.Index do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Curriculum

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Curriculum")}
        <:actions>
          <.button variant="primary" navigate={~p"/admin/curriculum/new"}>
            <.icon name="hero-plus" />{gettext("Ingest a new subject file.")}
          </.button>
        </:actions>
      </.header>

      <div class="w-full flex flex-col gap-4">
        <.index_ingestions ingestions={@streams.curriculum_ingestions} />

        <div class="mt-4 mx-auto w-fit">
          <.async_result :let={curriculum_stats} assign={@curriculum_stats}>
            <:loading><div class="skeleton" /></:loading>
            <:failed>{gettext("Failed to retrieve data")}</:failed>
            <div id="curriculum-stats" class="flex flex-row flex-wrap gap-4">
              <.subject_counts
                :for={{grade, subject_counts} <- curriculum_stats}
                subjects_count={subject_counts}
                grade={grade}
              />
            </div>
          </.async_result>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :subjects_count, :list, default: []
  attr :grade, :string, default: ""

  def subject_counts(assigns) do
    ~H"""
    <ul id={"grade-#{@grade}"} class="list bg-base-200 rounded-box shadow-md w-[384px]">
      <li class="p-4 pb-2 text-xs opacity-60 tracking-wide">{@grade}</li>

      <li
        :for={%{subject: subject, count: count} <- @subjects_count}
        class="list-row flex flex-row items-center"
      >
        <div class="text-xs uppercase font-semibold opacity-60 flex-1">
          {subject |> String.capitalize()}
        </div>
        <div class="">{count}</div>
      </li>
    </ul>
    """
  end

  attr :ingestions, :list

  def index_ingestions(assigns) do
    ~H"""
    <ul class="list bg-base-200 rounded-box shadow-md w-fit mx-auto">
      <li class="p-4 pb-2 text-xs opacity-60 tracking-wide">{gettext("Last 5 ingestions")}</li>

      <li :for={{_, ingestion} <- @ingestions} class="list-row">
        <div>{ingestion.year}</div>
        <div>{ingestion.subject}</div>
        <div class={[
          ingestion.state == "finished" && "badge badge-success",
          ingestion.state == "error" && "badge badge-error",
          ingestion.state == "created" && "badge badge-info",
          ingestion.state == "processing" && "badge badge-warning"
        ]}>
          {ingestion.state}
        </div>
        <.link
          :if={ingestion.sentry_id}
          navigate={"https://teachercoop.sentry.io/issues/" <> Integer.to_string(ingestion.sentry_id)}
        >{ingestion.sentry_id}</.link>
      </li>
    </ul>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Curriculum.subscribe_curriculum_ingestions()
    end

    {:ok,
     socket
     |> assign(:current_scope, socket.assigns.current_scope)
     |> stream(:curriculum_ingestions, Curriculum.list_last_ingestions(5))
     |> assign_async(:curriculum_stats, fn ->
       {:ok,
        %{
          curriculum_stats:
            Curriculum.get_stats(2024)
            |> Enum.group_by(fn entry -> entry.grade end)
            |> Map.to_list()
        }}
     end)}
  end

  @impl true
  def handle_info(:ingestion_updated, socket) do
    {:noreply,
     stream(socket, :curriculum_ingestions, Curriculum.list_last_ingestions(5), reset: true)}
  end
end

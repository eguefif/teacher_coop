defmodule TeacherCoopWeb.AdminLive.DocumentsCountLive do
  use TeacherCoopWeb, :live_component
  alias TeacherCoop.Dashboard

  @impl true
  def render(assigns) do
    ~H"""
    <section class="ml-8 flex flex-row flex-wrap gap-2">
      <.stat_card
        title={gettext("Documents")}
        what={gettext("user")}
        stat={@documents_count}
        icon="hero-document"
        sub_title={gettext("past 7 days")}
      />
      <.stat_card
        title={gettext("User Count")}
        what={gettext("user")}
        stat={@users_count}
        sub_title="past 7 days"
        icon="hero-users"
      />
    </section>
    """
  end

  attr :title, :string, required: true
  attr :sub_title, :string, required: true
  attr :stat, Phoenix.LiveView.AsyncResult, required: true
  attr :icon, :string
  attr :what, :string

  def stat_card(assigns) do
    ~H"""
    <div class="flex-1">
      <.async_result :let={stat} assign={@stat}>
        <:loading>
          <span class="skeleton w-[384px] h-[128px]"></span>
        </:loading>
        <:failed :let={_error}>error</:failed>
        <div class="flex flex-row justify-between card bg-base-200 shadow-md p-[16px] h-[128px] items-center">
          <div class="flex flex-col flex-4 gap-[8px]">
            <div class="text-md">{@title}</div>
            <div class="text-4xl">{stat.total}</div>
            <div if={stat.sub > 0}>
              <span class="text-md">{stat.sub} {@what} {@sub_title}</span>
            </div>
          </div>
          <div class="flex-1">
            <.icon name={@icon} class="size-8" />
          </div>
        </div>
      </.async_result>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    current_scope = assigns.current_scope

    {:ok,
     socket
     |> assign(:assigns, assigns)
     |> assign_async(:documents_count, fn ->
       {:ok,
        %{
          documents_count: %{
            total: Dashboard.documents_count(current_scope),
            sub: Dashboard.past_documents_count(current_scope, 7)
          }
        }}
     end)
     |> assign_async(:users_count, fn ->
       {:ok,
        %{
          users_count: %{
            total: Dashboard.users_count(current_scope),
            sub: Dashboard.past_users_count(current_scope, 7)
          }
        }}
     end)}
  end
end

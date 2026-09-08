defmodule TeacherCoopWeb.AdminLive.DocumentsCountLive do
  use TeacherCoopWeb, :live_component
  alias TeacherCoop.Dashboard

  @impl true
  def render(assigns) do
    ~H"""
    <section class="flex flex-row flex-wrap gap-2">
      <.documents_counts stat={@documents_count} />
      <.users_counts stat={@users_count} />
    </section>
    """
  end

  attr :stat, Phoenix.LiveView.AsyncResult, required: true

  def documents_counts(assigns) do
    ~H"""
    <div id="documents-counts" class="flex-1">
      <.async_result :let={stat} assign={@stat}>
        <:loading>
          <span class="skeleton w-[384px] h-[128px]"></span>
        </:loading>
        <:failed :let={_error}>error</:failed>
        <div class="flex flex-row justify-between card bg-base-200 shadow-md p-[16px] h-[128px] items-center">
          <div class="flex flex-col flex-4 gap-[8px]">
            <div class="text-md">{gettext("Document")}</div>
            <div class="text-4xl">{stat.total}</div>
            <div if={stat.sub > 0}>
              <span class="text-md">{stat.sub} {gettext(" new documents in the past 7 days")}</span>
            </div>
          </div>
          <div class="flex-1">
            <.icon name="hero-document" class="size-8" />
          </div>
        </div>
      </.async_result>
    </div>
    """
  end

  attr :stat, Phoenix.LiveView.AsyncResult, required: true

  def users_counts(assigns) do
    ~H"""
    <div id="users-counts" class="flex-1">
      <.async_result :let={stat} assign={@stat}>
        <:loading>
          <span class="skeleton w-[384px] h-[128px]"></span>
        </:loading>
        <:failed :let={_error}>error</:failed>
        <div class="flex flex-row justify-between card bg-base-200 shadow-md p-[16px] h-[128px] items-center">
          <div class="flex flex-col flex-4 gap-[8px]">
            <div class="text-md">{gettext("Users")}</div>
            <div class="text-4xl">{stat.total}</div>
            <div if={stat.sub > 0}>
              <span class="text-md">{stat.sub} {gettext("new users in the past 7 days.")}</span>
            </div>
          </div>
          <div class="flex-1">
            <.icon name="hero-users" class="size-8" />
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

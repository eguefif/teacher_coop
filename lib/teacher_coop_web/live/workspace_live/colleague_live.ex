defmodule TeacherCoopWeb.WorkspaceLive.ColleagueLive.Index do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.TeacherNetworking
  alias TeacherCoop.Accounts
  alias TeacherCoopWeb.Reusables

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("My Colleagues")}
        <:actions>
          <.button navigate={~p"/workspace/"}><.icon name="hero-arrow-left" /></.button>
        </:actions>
      </.header>
      <div class="flex flex-col gap-8">
        <.live_component
          module={Reusables.AutocompleteInput}
          id="teacher-search"
          name="teacher-search"
          allow_input_edit={true}
          autocomplete_list={@autocomplete}
          on_user_typing={fn input_value -> send(self(), {:input_value, input_value}) end}
          on_autocomplete_submit={fn colleague -> send(self(), {:add_colleague, colleague}) end}
        />
        <ul class="list">
          <li :for={colleague <- @new_colleagues_list}>
            {colleague.value}
            <.button type="button" phx-click="user-invite-colleague" phx-value-id={colleague.id}>
              {gettext("Invite")}
            </.button>
            <.button
              type="button"
              phx-click="user-remove-colleague-from-new-list"
              phx-value-id={colleague.id}
              variant="primary"
            >
              <.icon name="hero-x-mark" class="size-6" />
            </.button>
          </li>
        </ul>
        <div class="flex flex-col gap-8">
          <h1>{gettext("My Colleagues")}</h1>
          <ul class="list">
            <li :for={colleague <- @colleagues} class="list-row">
              {colleague.fullname}({colleague.state})
              <.button
                type="button"
                phx-click="user-remove-connection"
                phx-value-id={colleague.colleague_id}
                data-confirm={gettext("Are you sure?")}
              >
                <.icon name="hero-x-mark" class="size-6" />
              </.button>
            </li>
          </ul>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _sessions, socket) do
    colleagues = TeacherNetworking.get_connections(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:autocomplete, [])
     |> assign(:colleagues, colleagues)
     |> assign(:new_colleagues_list, [])}
  end

  @impl true
  def handle_info({:add_colleague, colleague}, socket) do
    new_list = socket.assigns.new_colleagues_list ++ [colleague]
    IO.inspect(new_list)
    {:noreply, socket |> assign(:new_colleagues_list, new_list)}
  end

  @impl true
  def handle_info({:input_value, input_value}, socket) do
    new_list =
      Accounts.search_user(input_value)
      |> Enum.map(fn entry -> %{id: entry.id, value: entry.fullname} end)

    {:noreply, socket |> assign(:autocomplete, new_list)}
  end

  @impl true
  def handle_event("user-remove-colleague-from-new-list", %{"id" => id}, socket) do
    new_list =
      Enum.reject(socket.assigns.new_colleagues_list, fn entry ->
        entry.id == String.to_integer(id)
      end)

    {:noreply, socket |> assign(:new_colleagues_list, new_list)}
  end

  @impl true
  def handle_event("user-invite-colleague", %{"id" => id}, socket) do
    id = String.to_integer(id)

    new_list =
      case TeacherNetworking.create_pending_connection(socket.assigns.current_scope, id) do
        :already_pending_connection ->
          socket.assigns.new_colleagues_list

        {:ok, _} ->
          Enum.reject(socket.assigns.new_colleagues_list, fn entry -> entry.id == id end)
      end

    colleagues = TeacherNetworking.get_connections(socket.assigns.current_scope)

    {:noreply,
     socket |> assign(:new_colleagues_list, new_list) |> assign(:colleagues, colleagues)}
  end

  def handle_event("user-remove-connection", %{"id" => id}, socket) do
    TeacherNetworking.remove_connection_by_id(socket.assigns.current_scope, id)
    colleagues = TeacherNetworking.get_connections(socket.assigns.current_scope)
    {:noreply, socket |> assign(:colleagues, colleagues)}
  end
end

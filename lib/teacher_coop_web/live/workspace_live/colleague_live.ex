defmodule TeacherCoopWeb.WorkspaceLive.ColleagueLive.Index do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.TeacherNetworking
  alias TeacherCoop.Accounts
  alias TeacherCoopWeb.Reusables

  # TODO:
  # -[ ] Extract tag like autocomplete logic in a component
  # - [ ] Wrap into a form with a button that will send invitation for all the user in the list
  # - [ ] component autocomplete should not display the list of entry
  # -[ ] Add another callback that will return the list for the autocomplete

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
          input_value=""
          nav={nil}
          autocomplete_list={@autocomplete}
          on_user_typing={fn input_value -> send(self(), {:input_value, input_value}) end}
          on_autocomplete_submit={fn colleague -> send(self(), {:add_colleague, colleague}) end}
        />
        <ul class="list">
          <li :for={colleague <- @new_colleagues_list}>{colleague.value}</li>
        </ul>
        <div class="flex flex-col gap-8">
          <h1>{gettext("My Colleagues")}</h1>
          <ul class="list">
            <li :for={colleague <- @colleagues} class="list-row">{colleague.fullname}</li>
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
end

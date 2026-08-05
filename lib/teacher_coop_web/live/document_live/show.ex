defmodule TeacherCoopWeb.DocumentLive.Show do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Library

  # TODO:
  # - [ ] Present files
  # - [ ] Present correctly other information
  # - [ ] Find a good layout

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col gap-[64px]">
        <.header>
          {@document.title}
          <span :if={@current_scope.user.id != @document.user_id}>
            {@document.user.id}
          </span>
          <:actions>
            <.button navigate={@return_to}>
              <.icon name="hero-arrow-left" />
            </.button>
            <.button
              :if={@current_scope != nil && @current_scope.user.id == @document.user_id}
              variant="primary"
              navigate={~p"/documents/#{@document}/edit?return_to=show"}
            >
              <.icon name="hero-pencil-square" /> {gettext("Edit")} {gettext("document")}
            </.button>
          </:actions>
        </.header>

        <.display_objectives objectives={@document.objectives} />

        <div class="flex gap-[96px]">
          <.description description={@document.description} />
          <.display_files files={@document.files} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :description, :string, default: ""

  def description(assigns) do
    ~H"""
    <div class="flex flex-col gap-[32px]">
      <div class="text-md uppercase opacity-60 text-center">{gettext("Description")}</div>
      <div class="text-justify">{@description}</div>
    </div>
    """
  end

  attr :objectives, :list, default: []

  def display_objectives(assigns) do
    ~H"""
    <div>
      <ul class="list bg-base-200 rounded-box shadow-md">
        <li
          :for={{objective, num} <- Enum.with_index(@objectives)}
          class="list-row"
        >
          <div class="text-4xl font-thin opacitiy-30 tabular-nums content-center">{num + 1}</div>
          <div class="content-center">
            <.subject_badge subject={objective.subject} />
          </div>
          <.objective objective={objective} />
        </li>
      </ul>
    </div>
    """
  end

  attr :objective, :string, default: ""

  def objective(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 list-col-grow">
      <div class="text-xs uppercase text-semibold opacity-60">
        {@objective.strand} - {@objective.grade}
      </div>
      <div class="text-lg">{@objective.goal}</div>
    </div>
    """
  end

  attr :files, :list, default: []

  def display_files(assigns) do
    ~H"""
    <div class="flex flex-col gap-[24px]">
      <div class="text-md uppercase opacity-60 text-center">{gettext("Files")}</div>
      <div
        :for={file <- @files}
        class="p-[16px] bg-neutral w-[384px] shadow-sm rounded-sm flex justify-between"
      >
        <div>{file.filename}</div>
        <.link href={~p"/files/#{file}"}>
          <.icon
            name="hero-arrow-down-tray"
            class="size-[24] scale-100 hover:scale-114 transform-transition duration-100 ease-in-out"
          />
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id, "return_to" => "search"}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Document")
     |> assign(:document, Library.get_document!(id))
     |> assign(:return_to, ~p"/search")}
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Document")
     |> assign(:document, Library.get_document!(id))
     |> assign(:return_to, ~p"/documents")}
  end

  @impl true
  def handle_info(
        {:updated, %TeacherCoop.Library.Document{id: id} = document},
        %{assigns: %{document: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :document, document)}
  end

  def handle_info(
        {:deleted, %TeacherCoop.Library.Document{id: id}},
        %{assigns: %{document: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current document was deleted.")
     |> push_navigate(to: ~p"/documents")}
  end

  def handle_info({type, %TeacherCoop.Library.Document{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end

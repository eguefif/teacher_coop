defmodule TeacherCoopWeb.SearchLive.Search do
  use TeacherCoopWeb, :live_view

  import TeacherCoop.DocumentLive.Component
  alias TeacherCoop.Discovery

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col items-center gap-[64px]">
        <form
          phx-change="update-search"
          phx-submit="trigger-search"
          class="flex flex-row gap-[48px] items-baseline"
        >
          <.input
            id="search"
            name="search"
            type="text"
            value={@search_terms}
            placeholder="Un petit prince..."
            class="input w-150 h-14 rounded-4xl"
          />
          <div>
            <.button
              name="trigger-search"
              class="btn btn-primary btn-soft btn-lg rounded-xl"
            >
              {gettext("Search")}
            </.button>
          </div>
        </form>
        <div :if={@results != nil} class="max-w-200 flex flex-col gap-[64px]">
          <div :for={{result, position} <- Enum.with_index(@results)} class="w-200">
            <.result result={result} preview_file={@preview_file} position={position} />
          </div>
        </div>
      </div>
      <pre><%= inspect @results, pretty: true %></pre>
    </Layouts.app>
    """
  end

  attr :position, :integer
  attr :result, :map
  attr :preview_file, :integer, default: nil

  def result(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div class="flex flex-row gap-4 items-baseline">
        <div class="text-lg">
          <.link
            class="btn-ghost hover:underline"
            navigate={~p"/documents/#{@result.id}?return_to=search"}
          >
            <div class="text-primary text-xl">{@result.title}</div>
          </.link>
        </div>
      </div>
      <div class="text-md font-semibold uppercase opacity-60">
        {@result.institution_type} - {@result.grade}
      </div>
      <div class="text-base text-justify">{@result.description}</div>
      <div class="collapse collapse-arrow bg-base-100 border-base-300">
        <input id={"collapsable-checkbox-#{@result.id}"} type="checkbox" phx-update="ignore" />
        <div class="collapse-title font-semibold after:start-5 after:end-auto pe-4 ps-12">
          {gettext("See more")}
        </div>
        <div class="collapse-content flex flex-col gap-[32px]">
          <.objectives objectives={@result.objectives} />
          <.files files={@result.files} preview_file={@preview_file} />
          <div
            phx-click="user-click-download-all"
            phx-value-position={@position}
            class="mx-auto"
          >
            <.download_all_button document={@result} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :objectives, :list, default: []

  def objectives(assigns) do
    ~H"""
    <div>
      <ul :if={@objectives != []} class="list bg-base-100 rounded-box shadow-md">
        <li class="text-lg opacity-60 p-4 pb-2">{gettext("Objectives")}</li>
        <li
          :for={objective <- @objectives}
          class="list-row"
        >
          <div>{objective.goal}</div>
        </li>
      </ul>
    </div>
    """
  end

  attr :files, :list, default: nil
  attr :preview_file, :integer, default: nil

  def files(assigns) do
    ~H"""
    <div>
      <div class="text-xl mb-[24px]">{gettext("Files")}</div>
      <div :if={@files != []} class="flex flex-row gap-[8px] flex-wrap">
        <div
          :for={file <- @files}
          class="card bg-base-200 w-[192px] shadow-sm"
        >
          <.file_card file={file} />
          <.preview_modal file={file} preview_file={@preview_file} />
        </div>
      </div>
    </div>
    """
  end

  attr :file, :map, default: nil

  def file_card(assigns) do
    ~H"""
    <div class="card-body">
      <div class="card-title mb-[32px]">{@file.filename}</div>
      <div class="card-actions justify-around">
        <button
          type="button"
          id={"preview-button-#{@file.id}"}
          phx-click={JS.push("user-preview-file")}
          phx-value-id={@file.id}
        >
          <div class="tooltip" data-tip={gettext("Preview")}>
            <.icon
              name="hero-document-magnifying-glass"
              class="size-[32px] scale-100 hover:scale-120 transform-transition duration-100 ease-in-out cursor-pointer"
            />
          </div>
        </button>
        <div class="tooltip" data-tip={gettext("Download")}>
          <.link href={~p"/files/#{@file}"}>
            <.icon
              name="hero-arrow-down-tray"
              class="size-[32px] scale-100 hover:scale-120 transform-transition duration-100 ease-in-out cursor-pointer"
            />
          </.link>
        </div>
      </div>
    </div>
    """
  end

  attr :file, :map, default: nil
  attr :preview_file, :integer, default: nil

  def preview_modal(assigns) do
    ~H"""
    <dialog id={"modal-file-#{@file.id}"} class="modal">
      <div class="modal-box">
        <form method="dialog">
          <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        </form>
        <div
          :if={@preview_file == @file.id}
          phx-mounted={JS.dispatch("modal:open")}
          data={"modal-file-#{@file.id}"}
          class="flex flex-col gap-4"
        >
          <div class="text-center">{@file.filename}</div>
          <object
            data={~p"/files/#{@file}?preview=true"}
            type="application/pdf"
            width="100%"
            height="600px"
          >
            {gettext("Reading preview not supported")}
          </object>
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button>{gettext("close")}</button>
      </form>
    </dialog>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope =
      if Map.has_key?(socket.assigns, :current_scope), do: socket.assigns.current_scope, else: nil

    search_session = Discovery.create_search_session(scope)

    {:ok,
     socket
     |> assign_new(:current_scope, fn -> scope end)
     |> assign(:search_terms, "")
     |> assign(:preview_file, nil)
     |> assign(results: [])
     |> assign(:search_session, search_session)}
  end

  @impl true
  def handle_event("trigger-search", %{}, socket) do
    search_session =
      Discovery.handle_search(socket.assigns.search_session, socket.assigns.search_terms)

    {:noreply,
     socket
     |> assign(:results, search_session.db_results)
     |> assign(:search_session, search_session)
     |> assign(:search_terms, socket.assigns.search_terms)}
  end

  @impl true
  def handle_event("update-search", %{"search" => search_terms}, socket) do
    {:noreply,
     socket |> assign(:search_terms, search_terms) |> assign(:results, socket.assigns.results)}
  end

  @impl true
  def handle_event("user-preview-file", %{"id" => id}, socket) do
    {:noreply, socket |> assign(:preview_file, String.to_integer(id))}
  end

  @impl true
  def handle_event("user-click-download-all", %{"position" => click_position}, socket) do
    Discovery.save_successful_search(socket.assigns.search_session, click_position)
    {:noreply, socket}
  end
end

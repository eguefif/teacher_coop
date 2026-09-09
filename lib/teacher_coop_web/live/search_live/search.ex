defmodule TeacherCoopWeb.SearchLive.Search do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Discovery

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col items-center gap-[64px]">
        <.form
          id="search-form"
          for={@form}
          phx-submit="trigger-search"
          class="flex flex-row gap-[48px] items-baseline"
        >
          <.input
            id="search_terms"
            name="search_terms"
            type="text"
            field={@form[:search_terms]}
            placeholder="Un petit prince..."
            class="input w-150 h-14 rounded-4xl"
          />
          <footer>
            <.button
              phx-disable-with={gettext("Searching...")}
              name="trigger-search-button"
              class="btn btn-primary btn-soft btn-lg rounded-xl"
            >
              {gettext("Search")}
            </.button>
          </footer>
        </.form>
        <div
          :if={@results != nil && @form[:search_terms].value != ""}
          class="max-w-200 flex flex-col gap-[64px]"
        >
          <div :for={{result, position} <- Enum.with_index(@results)} class="w-200">
            <.result result={result} preview_file={@preview_file} position={position} />
          </div>
        </div>
        <div
          :if={@results == [] && @form[:search_terms].value != ""}
          class="max-w-200 flex flex-col gap-[64px]"
        >
          {gettext("Oops no result for that search....")}
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
          <div :if={@result.files != []} class="w-full">
            <.files position={@position} files={@result.files} preview_file={@preview_file} />
            <.link
              id={"download-all-button-#{@result.id}"}
              phx-click="search-success"
              phx-value-position={@position}
              phx-value-download-link={~p"/documents/download/#{@result}"}
              class="btn btn-primary"
            >{gettext("Download all")}</.link>
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
  attr :position, :integer, required: true

  def files(assigns) do
    ~H"""
    <div>
      <div class="text-xl mb-[24px]">{gettext("Files")}</div>
      <div :if={@files != []} class="flex flex-row gap-[8px] flex-wrap">
        <div
          :for={file <- @files}
          class="card bg-base-200 w-[192px] shadow-sm"
        >
          <.file_card file={file} position={@position} />
          <.preview_modal file={file} preview_file={@preview_file} />
        </div>
      </div>
    </div>
    """
  end

  attr :file, :map, default: nil
  attr :position, :integer, required: true

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
          <.link
            phx-click="search-success"
            phx-value-position={@position}
            id={"download-button-#{@file.id}"}
            phx-value-download-link={~p"/files/#{@file}"}
          >
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

    {:ok,
     socket
     |> assign_new(:current_scope, fn -> scope end)
     |> assign(:form, to_form(Discovery.change_search(nil, %{search_terms: ""}, scope)))
     |> assign(:preview_file, nil)
     |> assign(results: [])}
  end

  @impl true
  def handle_event(
        "trigger-search",
        %{"search_terms" => search_terms},
        %{assigns: %{search_session: search_session}} = socket
      ) do
    scope = socket.assigns.current_scope

    case Discovery.handle_search(search_terms, scope, search_session) do
      {:error, search_session, changeset, hits, _db_hits} ->
        {:noreply,
         socket
         |> assign(:results, hits)
         |> assign(:search_session, search_session)
         |> assign(:search, nil)
         |> assign(:form, to_form(changeset))}

      {:ok, search_session, search, hits, _} ->
        {:noreply,
         socket
         |> assign(:results, hits)
         |> assign(:search_session, search_session)
         |> assign(:search, search)
         |> assign(
           :form,
           to_form(Discovery.change_search(nil, %{search_terms: search_terms}, scope))
         )}
    end
  end

  @impl true
  def handle_event("trigger-search", %{"search_terms" => search_terms}, socket) do
    scope = socket.assigns.current_scope

    case Discovery.handle_search(search_terms, scope) do
      {:error, search_session, changeset, hits, _db_hits} ->
        {:noreply,
         socket
         |> assign(:results, hits)
         |> assign(:search_session, search_session)
         |> assign(:search, nil)
         |> assign(:form, to_form(changeset))}

      {:ok, search_session, search, hits, _} ->
        {:noreply,
         socket
         |> assign(:results, hits)
         |> assign(:search_session, search_session)
         |> assign(:search, search)
         |> assign(
           :form,
           to_form(Discovery.change_search(nil, %{search_terms: search_terms}, scope))
         )}
    end
  end

  @impl true
  def handle_event("user-preview-file", %{"id" => id}, socket) do
    {:noreply, socket |> assign(:preview_file, String.to_integer(id))}
  end

  @impl true
  def handle_event(
        "search-success",
        %{"position" => click_position, "download-link" => redirect_link},
        socket
      ) do
    {:ok, search} =
      Discovery.mark_search_as_succes(
        socket.assigns.search,
        String.to_integer(click_position),
        socket.assigns.current_scope,
        socket.assigns.search_session,
        "download"
      )

    {:noreply,
     socket
     |> assign(:search_session, socket.assigns.search_session)
     |> assign(:search, search)
     |> redirect(to: redirect_link)}
  end
end

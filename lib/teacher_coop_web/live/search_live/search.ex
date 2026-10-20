defmodule TeacherCoopWeb.SearchLive.Search do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Discovery

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col items-center gap-[32px] lg:gap-[64px]">
        <.search_form form={@form} />
        <.show_results form={@form} preview_file={@preview_file} results={@results} />
      </div>
    </Layouts.app>
    """
  end

  attr :form, :map

  def search_form(assigns) do
    ~H"""
    <.form
      id="search-form"
      for={@form}
      phx-submit="trigger-search"
      class="flex flex-col lg:flex-row gap-[16px] lg:gap-[48px] items-center lg:items-baseline"
    >
      <.input
        id="search_terms"
        name="search_terms"
        type="text"
        field={@form[:search_terms]}
        placeholder="Un petit prince..."
        class="input w-[256px] lg:w-[384px] h-14 rounded-4xl"
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
    """
  end

  attr :results, :map
  attr :form, :map
  attr :preview_file, :map

  def show_results(assigns) do
    ~H"""
    <div
      :if={@results != nil && @form[:search_terms].value != ""}
      class="max-w-200 flex flex-col gap-[64px]"
    >
      <div :for={{result, position} <- Enum.with_index(@results)} class="w-200">
        <.result_info result={result} />
        <.result_files result={result} preview_file={@preview_file} position={position} />
      </div>
    </div>
    <div
      :if={@results == [] && @form[:search_terms].value != ""}
      class="max-w-200 flex flex-col gap-[64px]"
    >
      {gettext("Oops no result for that search....")}
    </div>
    """
  end

  attr :result, :map

  def result_info(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 items-baseline">
      <div class="text-lg">
        <.link
          class="btn-ghost hover:underline"
          navigate={~p"/documents/#{@result.id}?return_to=search"}
        >
          <div class="text-primary text-xl">{@result.title}</div>
        </.link>
      </div>
      <div class="text-md font-semibold uppercase opacity-60">
        {@result.institution_type} - {@result.grade}
      </div>
      <div class="text-base text-justify">{@result.description}</div>
    </div>
    """
  end

  attr :result, :map
  attr :position, :integer
  attr :preview_file, :integer, default: nil

  def result_files(assigns) do
    ~H"""
    <div class="collapse collapse-arrow bg-base-100 border-base-300">
      <input id={"collapsable-checkbox-#{@result.id}"} type="checkbox" phx-update="ignore" />
      <div class="collapse-title font-semibold after:start-5 after:end-auto pe-4 ps-12">
        {gettext("See more")}
      </div>
      <div class="collapse-content flex flex-col gap-[32px]">
        <.objectives objectives={@result.objectives} />
        <div :if={@result.files != []} class="flex flex-col w-full gap-[16px]">
          <.files
            position={@position}
            files={@result.files}
            preview_file={@preview_file}
          />
          <.link
            id={"download-all-button-#{@result.id}"}
            phx-click="search-success"
            phx-value-position={@position}
            phx-value-download-link={~p"/documents/download/#{@result}"}
            class="btn btn-primary self-center w-[128px] p-[32px]"
          >{gettext("Download all")}</.link>
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
      <div class="text-xl mb-[24px] font-bold">{gettext("Files")}</div>
      <div :if={@files != []} class="flex flex-row gap-[32px] flex-wrap">
        <div :for={file <- @files}>
          <.file_card file={file} />
          <.preview_modal file={file} preview_file={@preview_file} position={@position} />
        </div>
      </div>
    </div>
    """
  end

  attr :file, :map, default: nil

  def file_card(assigns) do
    ~H"""
    <.link
      id={"preview-button-#{@file.id}"}
      phx-click={JS.push("user-preview-file")}
      phx-value-id={@file.id}
    >
      <div class="card bg-base-200 w-[192px] shadow-sm p-[16px] scale-100 hover:scale-104 duration-200 transition-transform ease-in-out">
        <div class="card-title mx-auto">
          <.icon
            name="hero-document"
            class="size-[64px]"
          />
        </div>
        <div class="card-body">
          {@file.filename}
        </div>
        <div class="card-actions justify-around"></div>
      </div>
    </.link>
    """
  end

  attr :file, :map, default: nil
  attr :preview_file, :integer, default: nil
  attr :position, :integer

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
          class="flex flex-col gap-4 items-center"
        >
          <div class="text-center text-xl font-bold">{@file.filename}</div>
          <div class="tooltip" data-tip={gettext("Download")}>
            <.link
              class="btn btn-primary self-center"
              phx-click="search-success"
              phx-value-position={@position}
              id={"download-button-#{@file.id}"}
              phx-value-download-link={~p"/files/#{@file}"}
            >
              <.icon
                name="hero-arrow-down-tray"
                class="size-[32px] scale-100 hover:scale-120 transform-transition duration-100 ease-in-out cursor-pointer"
              />
              {gettext("Download")}
            </.link>
          </div>
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

    search_session_id = Ecto.UUID.generate(version: 7)

    {hits, search} =
      case Discovery.handle_search("fract", scope, search_session_id) do
        {:ok, search, hits, _} -> {hits, search}
        _ -> raise "No"
      end

    {:ok,
     socket
     |> assign_new(:current_scope, fn -> scope end)
     |> assign(:search_session_id, search_session_id)
     |> assign(:form, to_form(Discovery.change_search(%{search_terms: "fract"}, scope)))
     |> assign(:preview_file, nil)
     |> assign(:results, hits)
     |> assign(:search, search)}
  end

  @impl true
  def handle_event(
        "trigger-search",
        %{"search_terms" => search_terms},
        %{assigns: %{search_session_id: search_session_id}} = socket
      ) do
    scope = socket.assigns.current_scope

    case Discovery.handle_search(search_terms, scope, search_session_id) do
      {:error, error_reason} when is_binary(error_reason) ->
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:results, [])
         |> assign(:search, nil)
         |> assign(:form, to_form(changeset))}

      {:ok, search, hits, _} ->
        {:noreply,
         socket
         |> assign(:results, hits)
         |> assign(:search, search)
         |> assign(
           :form,
           to_form(Discovery.change_search(%{search_terms: search_terms}, scope))
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
      Discovery.mark_search_as_success(
        socket.assigns.search,
        String.to_integer(click_position),
        socket.assigns.current_scope,
        socket.assigns.search_session_id,
        "download"
      )

    {:noreply,
     socket
     |> assign(:search, search)
     |> redirect(to: redirect_link)}
  end
end

defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace
  alias TeacherCoop.Workspace.Document

  # TODO:
  # - [ ] Improve UI

  ## Curriculum
  # The user can choose an curriculum item and customize it.
  # They can add several curriculum item
  # It's important that the user does not have to match the item. They can modify it if they want.

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <.form
        for={@form}
        id="document-form"
        phx-change="validate"
        phx-submit="save"
        class="flex flex-col gap-4"
      >
        <.input field={@form[:title]} type="text" label={gettext("Title")} />
        <.input field={@form[:description]} type="textarea" label={gettext("Description")} />
        <.curriculum_input
          curriculum={@curriculum}
          autocomplete={@autocomplete_curriculum}
          items={@curriculum_items}
          nav={@curriculum_nav}
          error={@curriculum_error}
        />
        <.tag_input
          tags={@tags}
          autocomplete_tags={@autocomplete_tags}
          tag={@tag_input}
          nav={@tag_nav}
          error={@tag_error}
        />
        <.files_list :if={Map.has_key?(assigns, :files) && @files != []} files={@files} />
        <.input_file uploads={@uploads} />
        <footer class="mx-auto">
          <.button phx-disable-with={gettext("Saving...")} variant="primary">
            {gettext("Save Document")}
          </.button>
          <.button navigate={return_path(@current_scope, @return_to, @document)}>
            {gettext("Cancel")}
          </.button>
        </footer>
      </.form>
      <p :for={error <- upload_errors(@uploads.files)} class="alert alert-danger">
        {error_to_string(error)}
      </p>
    </Layouts.app>
    """
  end

  attr :curriculum, :string, default: ""
  attr :autocomplete, :list, default: []
  attr :items, :list, default: []
  attr :nav, :integer, default: nil
  attr :error, :string

  def curriculum_input(assigns) do
    ~H"""
    <div class="fieldset">
      <label for="curriculum" class="static">
        <span class="label mb-1">{gettext("Curriculum")}</span>
        <div class="flex flex-row gap-2">
          <input
            type="text"
            id="curriculum"
            name="curriculum"
            value={@curriculum}
            class="w-full input"
            phx-hook=".SetValue"
            phx-change="curriculum-complete"
            phx-keydown="nav-curriculum"
            onkeydown="if(event.key==='Enter'){event.preventDefault();}"
            role="combobox"
            aria-expanded={@autocomplete != []}
            aria-autocomplete="list"
            aria-controls="curriculum-listbox"
            aria-activedescendant={@nav && "curriculum-option-#{@nav}"}
          />
          <button
            type="button"
            phx-click="add-curriculum-item"
            phx-value-item={@curriculum}
            aria-label={gettext("Add curriculum item")}
          >
            <.icon name="hero-plus-circle" class="size-8 shrink-0 text-gray-400" />
          </button>
        </div>
        <div
          :if={@autocomplete != []}
          class="flex flex-col gap-2 border-2 absolute rounded-md z-10"
          phx-click-away="close-curriculum-autocomplete"
        >
          <ul class="list bg-base-100 rounded-box shadow-md" role="listbox" id="curriculum-listbox">
            <li
              :for={{entry, index} <- Enum.with_index(@autocomplete)}
              id={"curriculum-option-#{index}"}
              role="option"
              aria-selected={@nav == index}
              tabindex="0"
              class={["list-row hover:bg-primary", @nav == index && "bg-primary"]}
              phx-click={
                JS.dispatch("phx:set-input-value", detail: %{id: "curriculum", value: entry})
                |> JS.push("set-curriculum", value: %{curriculum: entry})
              }
            >
              {entry}
            </li>
          </ul>
        </div>
      </label>
      <div :if={@items != []}>
        <ul class="m-2 p-2">
          <li :for={item <- @items}>
            {item}
            <button
              type="button"
              phx-click="remove-curriculum-item"
              phx-value-item={item}
              aria-label={gettext("Remove") <> " #{item}"}
            >
              <.icon name="hero-x-circle" class="size-6 hover:bg-primary" />
            </button>
          </li>
        </ul>
      </div>
      <div
        :if={@error}
        role="alert"
        aria-live="polite"
        class="text-error-content first-letter:capitalize"
      >
        {@error}
      </div>
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".SetValue">
      export default {
        mounted() {
          this.handleEvent("set-value", ({value}) => {
            this.el.value = value
          })
        }
      }
    </script>
    """
  end

  attr :tags, :list, default: []
  attr :autocomplete_tags, :list, default: []
  attr :tag, :string, default: ""
  attr :nav, :integer, default: nil
  attr :error, :string

  def tag_input(assigns) do
    ~H"""
    <div class="fieldset">
      <label for="tag" class="static">
        <span class="label mb-1">{gettext("Tags")}</span>
        <input
          type="text"
          id="tag"
          name="tag"
          value={@tag}
          class="w-full input"
          phx-change="tag-complete"
          phx-keydown="nav-tag"
          onkeydown="if(event.key==='Enter'){event.preventDefault();}"
          role="combobox"
          aria-expanded={@autocomplete_tags != []}
          aria-autocomplete="list"
          aria-controls="tag-listbox"
          aria-activedescendant={@nav && "tag-option-#{@nav}"}
        />
        <div
          :if={@autocomplete_tags != []}
          class="flex flex-col gap-2 border-2 absolute rounded-md z-10"
          phx-click-away="close-tag-autocomplete"
        >
          <ul class="list bg-base-100 rounded-box shadow-md" role="listbox" id="tag-listbox">
            <li
              :for={{tag, index} <- Enum.with_index(@autocomplete_tags)}
              id={"tag-option-#{index}"}
              role="option"
              aria-selected={@nav == index}
              tabindex="0"
              class={["list-row hover:bg-primary", @nav == index && "bg-primary"]}
              phx-click={
                JS.dispatch("phx:set-input-value", detail: %{id: "tag", value: ""})
                |> JS.push("add-tag", value: %{tag: tag})
              }
              phx-value-tag={tag}
            >
              {tag}
            </li>
          </ul>
        </div>
        <div class="flex flex-row gap-4 m-4">
          <article
            :for={tag <- @tags}
            class="badge badge-soft badge-lg badge-primary hover:badge-accent relative group"
          >
            {tag}
            <div
              role="button"
              tabindex="0"
              class="hidden btn btn-circle btn-xs absolute -right-2 -top-2 group-hover:flex"
              phx-click="remove-tag"
              phx-value-tag={tag}
              aria-label={gettext("Remove tag") <> " #{tag}"}
            >
              X
            </div>
          </article>
        </div>
      </label>
      <div
        :if={@error}
        role="alert"
        aria-live="polite"
        class="text-error-content first-letter:capitalize"
      >
        {@error}
      </div>
    </div>
    """
  end

  attr :files, :list, required: true

  def files_list(assigns) do
    ~H"""
    <span class="label mb-1">{gettext("Files")}</span>
    <div class="flex flex-col gap-1">
      <article :for={entry <- @files}>
        <.button
          type="button"
          phx-click="remove-file"
          phx-value-id={entry.id}
          data-confirm={gettext("Are you sure you want to delete this file?")}
          aria-label={gettext("Remove file") <> " #{entry.filename}"}
        >
          X
        </.button>
        <span class="text-xs">{entry.filename}</span>
      </article>
    </div>
    """
  end

  attr :uploads, :map, required: true

  def input_file(assigns) do
    ~H"""
    <div class="flex flex-row justify-start gap-8 w-full">
      <label
        for={@uploads.files.ref}
        phx-drop-target={@uploads.files.ref}
        class="flex flex-col items-center justify-center w-64 h-32 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100 phx-drop-target-active:bg-gray-300"
      >
        <div class="flex flex-col items-center justify-center">
          <.icon name="hero-cloud-arrow-up" class="size-10 shrink-0 text-gray-400" />
        </div>
        <div class="flex flex-col gap-2">
          <p class="text-sm text-gray-500">
            <span class="font-semibold">{gettext("Click to upload or drag and drop")}</span>
          </p>
          <p class="text-xs text-gray-400 mt-1 text-center">PDF, DOCX {gettext("up to 8MB")}</p>
        </div>
        <.live_file_input upload={@uploads.files} class="hidden" />
      </label>
      <div :if={@uploads.files.entries == []}>
        <p>{gettext("No files")}</p>
      </div>
      <div class="flex flex-col gap-1">
        <article :for={entry <- @uploads.files.entries}>
          <.remove_button entry={entry} action="cancel-upload" />
          <span class="text-xs">{entry.client_name}</span>
          <.file_error errors={upload_errors(@uploads.files, entry)} />
        </article>
      </div>
    </div>
    """
  end

  attr :entry, :map, required: true
  attr :action, :string, required: true

  def remove_button(assigns) do
    ~H"""
    <.button
      type="button"
      class="btn btn-primary w-4 h-4"
      variant="primary"
      phx-click={@action}
      phx-value-ref={@entry.ref}
      aria-label={gettext("Cancel upload") <> " #{@entry.client_name}"}
    >
      X
    </.button>
    """
  end

  attr :errors, :list

  def file_error(assigns) do
    ~H"""
    <span :if={@errors != []} class="relative group">
      <span><.icon name="hero-exclamation-triangle" class="text-red-500 w-4 h-4" /></span>
      <div class="absolute top-0 left-5 opacity-0 group-hover:opacity-100 transition-opacity duration-300 bg-red-100 text-red-700 text-xs p-2 rounded shadow z-10 w-max">
        <article :for={error <- @errors}>{error_to_string(error)}</article>
      </div>
    </span>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)
     |> allow_upload(:files, accept: ~w(.docx .pdf .txt .jpg .jpeg .png), max_entries: 20)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    document = Workspace.get_document!(socket.assigns.current_scope, id)
    files = Workspace.get_files(document.id)
    tags = if document.tags == nil, do: [], else: document.tags
    goals = if document.goals == nil, do: [], else: document.goals

    socket
    |> assign(:page_title, gettext("Edit Document"))
    |> assign(:document, document)
    |> assign(:files, files)
    |> assign(:tag_input, "")
    |> assign(:tag_error, "")
    |> assign(:tag_nav, nil)
    |> assign(:tags, tags)
    |> assign(:autocomplete_tags, [])
    |> assign(:curriculum, "")
    |> assign(:curriculum_nav, nil)
    |> assign(:curriculum_error, nil)
    |> assign(:curriculum_items, goals)
    |> assign(:autocomplete_curriculum, [])
    |> assign(:form, to_form(Workspace.change_document(socket.assigns.current_scope, document)))
  end

  defp apply_action(socket, :new, _params) do
    document = %Document{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, gettext("New Document"))
    |> assign(:document, document)
    |> assign(:tag_input, "")
    |> assign(:tag_error, "")
    |> assign(:tag_nav, nil)
    |> assign(:tags, [])
    |> assign(:autocomplete_tags, [])
    |> assign(:curriculum, "")
    |> assign(:curriculum_error, nil)
    |> assign(:curriculum_items, [])
    |> assign(:autocomplete_curriculum, [])
    |> assign(:form, to_form(Workspace.change_document(socket.assigns.current_scope, document)))
  end

  # Event file Input **********************************************************
  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("remove-file", %{"id" => id}, socket) do
    Workspace.delete_file!(id)
    files = Workspace.get_files(socket.assigns.document.id)
    {:noreply, assign(socket, :files, files)}
  end

  @impl true
  def handle_event("validate", %{"document" => document_params}, socket) do
    changeset =
      Workspace.change_document(
        socket.assigns.current_scope,
        socket.assigns.document,
        document_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  # Event Tag Input *************************************************************
  def handle_event("tag-complete", %{"tag" => tag}, socket) do
    autocomplete_tags =
      Workspace.autocomplete_tags(tag)
      |> Enum.filter(fn entry -> !Enum.any?(socket.assigns.tags, fn tag -> tag == entry end) end)

    {:noreply, assign(socket, :autocomplete_tags, autocomplete_tags)}
  end

  def handle_event("add-tag", %{"tag" => tag}, socket) do
    {:noreply, do_add_tag(socket, tag)}
  end

  def handle_event("remove-tag", %{"tag" => tag}, socket) do
    tags = Enum.filter(socket.assigns.tags, fn entry -> entry != tag end)

    {:noreply,
     assign(socket, :tags, tags)
     |> assign(:autocomplete_tags, [])
     |> assign(:tag_input, "")}
  end

  def handle_event("close-tag-autocomplete", %{}, socket) do
    {:noreply, assign(socket, :autocomplete_tags, [])}
  end

  def handle_event("nav-tag", %{"key" => key}, socket) do
    max_idx = Enum.count(socket.assigns.autocomplete_tags)
    IO.puts(socket.assigns.tag_nav)
    IO.puts(max_idx)

    case {key, socket.assigns.tag_nav} do
      {"ArrowUp", nil} ->
        {:noreply, assign(socket, :tag_nav, max_idx - 1)}

      {"ArrowDown", nil} ->
        {:noreply, assign(socket, :tag_nav, 0)}

      {"ArrowUp", idx} ->
        {:noreply, assign(socket, :tag_nav, calculate_new_nav(idx, max_idx, "up"))}

      {"ArrowDown", idx} ->
        {:noreply, assign(socket, :tag_nav, calculate_new_nav(idx, max_idx, "down"))}

      {"Enter", idx} when not is_nil(idx) ->
        tag = Enum.at(socket.assigns.autocomplete_tags, idx)
        {:noreply, do_add_tag(socket, tag)}

      {"Escape", _} ->
        {:noreply, assign(socket, :tag_nav, nil) |> assign(:autocomplete_tags, [])}

      _ ->
        {:noreply, socket}
    end
  end

  # Event Curriculum Input *************************************************************
  def handle_event("set-curriculum", %{"curriculum" => curriculum}, socket) do
    {:noreply, socket |> assign(:curriculum, curriculum) |> assign(:autocomplete_curriculum, [])}
  end

  def handle_event("curriculum-complete", %{"curriculum" => curriculum}, socket)
      when byte_size(curriculum) > 3 do
    results = Workspace.autocomplete_curriculum(curriculum)

    {:noreply,
     socket |> assign(:autocomplete_curriculum, results) |> assign(:curriculum, curriculum)}
  end

  def handle_event("curriculum-complete", %{"curriculum" => curriculum}, socket) do
    {:noreply, socket |> assign(:autocomplete_curriculum, []) |> assign(:curriculum, curriculum)}
  end

  def handle_event("close-curriculum-autocomplete", %{}, socket) do
    {:noreply, assign(socket, :autocomplete_curriculum, [])}
  end

  def handle_event("add-curriculum-item", %{"item" => item}, socket) do
    {:noreply, do_add_curriculum_item(socket, item)}
  end

  def handle_event("nav-curriculum", %{"key" => key, "value" => value}, socket) do
    max_idx = Enum.count(socket.assigns.autocomplete_curriculum)

    case {key, socket.assigns.curriculum_nav} do
      {"ArrowUp", nil} ->
        {:noreply, assign(socket, :curriculum_nav, max_idx - 1)}

      {"ArrowDown", nil} ->
        {:noreply, assign(socket, :curriculum_nav, 0)}

      {"ArrowUp", idx} ->
        {:noreply, assign(socket, :curriculum_nav, calculate_new_nav(idx, max_idx, "up"))}

      {"ArrowDown", idx} ->
        {:noreply, assign(socket, :curriculum_nav, calculate_new_nav(idx, max_idx, "down"))}

      {"Enter", idx} when not is_nil(idx) ->
        item = Enum.at(socket.assigns.autocomplete_curriculum, idx)

        {:noreply,
         socket
         |> assign(:curriculum, item)
         |> assign(:curriculum_nav, nil)
         |> assign(:autocomplete_curriculum, [])
         |> push_event("set-value", %{value: item})}

      {"Enter", nil} ->
        {:noreply, do_add_curriculum_item(socket, value)}

      {"Escape", _} ->
        {:noreply, assign(socket, :curriculum_nav, nil) |> assign(:autocomplete_curriculum, [])}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("remove-curriculum-item", %{"item" => item}, socket) do
    filtered_items = Enum.filter(socket.assigns.curriculum_items, fn entry -> entry != item end)
    {:noreply, assign(socket, :curriculum_items, filtered_items)}
  end

  # Event Form save *************************************************************
  def handle_event("save", %{"document" => document_params}, socket) do
    files = get_files_from_uploads(socket)
    document_params = Map.put(document_params, "tags", socket.assigns.tags)

    document_params =
      Map.put(document_params, "goals", socket.assigns.curriculum_items)

    save_document(socket, socket.assigns.live_action, document_params, files)
  end

  def get_files_from_uploads(socket) do
    consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
      dest =
        Path.join(
          Application.app_dir(:teacher_coop, "priv/static/uploads"),
          Path.basename(path)
        )

      File.cp!(path, dest)
      {:ok, %{path: dest, filename: entry.client_name, format: entry.client_type}}
    end)
  end

  defp save_document(socket, :edit, document_params, files) do
    case Workspace.update_document(
           socket.assigns.current_scope,
           socket.assigns.document,
           files,
           document_params
         ) do
      {:ok, document} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Document updated successfully"))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, document)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_document(socket, :new, document_params, files) do
    case Workspace.create_document(socket.assigns.current_scope, files, document_params) do
      {:ok, document} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Document created successfully"))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, document)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _document), do: ~p"/workspace/documents"
  defp return_path(_scope, "show", document), do: ~p"/workspace/documents/#{document.id}"

  # File uploads Error Handling *********************************************************
  defp error_to_string(:too_many_files), do: gettext("You added too many files.")
  defp error_to_string(:too_large), do: gettext("File too large.")
  defp error_to_string(:not_accepted), do: gettext("This file format is not accepted.")

  # Utility functions for accessiblity navigation *****************************************
  defp calculate_new_nav(idx, max_idx, "down") when idx + 1 == max_idx, do: 0
  defp calculate_new_nav(idx, _, "down"), do: idx + 1
  defp calculate_new_nav(idx, max_idx, "up") when idx - 1 < 0, do: max_idx - 1
  defp calculate_new_nav(idx, _, "up"), do: idx - 1

  # Add functions **********************************************
  defp do_add_curriculum_item(socket, item) do
    goals = socket.assigns.curriculum_items ++ [item]

    changeset =
      Workspace.validate_change(
        socket.assigns.current_scope,
        %TeacherCoop.Workspace.Document{},
        %{goals: goals}
      )

    error = Enum.find(changeset.errors, fn entry -> elem(entry, 0) == :goals end)

    case error != nil do
      true ->
        assign(socket, :curriculum_error, elem(error, 1) |> translate_error())

      false ->
        socket
        |> assign(:curriculum_items, goals)
        |> assign(:curriculum_error, nil)
        |> assign(:curriculum_nav, nil)
        |> assign(:autocomplete_curriculum, [])
    end
  end

  defp do_add_tag(socket, tag) do
    tags = socket.assigns.tags ++ [tag]

    changeset =
      Workspace.validate_change(
        socket.assigns.current_scope,
        %TeacherCoop.Workspace.Document{},
        %{tags: tags}
      )

    error = Enum.find(changeset.errors, fn entry -> elem(entry, 0) == :tags end)

    case error != nil do
      true ->
        assign(socket, :tag_error, elem(error, 1) |> translate_error())

      false ->
        socket
        |> assign(:tags, tags)
        |> assign(:tag_error, "")
        |> assign(:tag_nav, nil)
        |> assign(:autocomplete_tags, [])
        |> assign(:tag_input, "")
    end
  end
end

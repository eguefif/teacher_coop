defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace
  alias TeacherCoop.Workspace.Document

  # TODO:
  # - [x] Display one file error correctly
  # - [x] Persist document (description)
  # - [x] Persist files
  # - [x] Update edit form.
  # - [ ] Work on accessibility
  # - [x] Add a tag document input (special auto complete input, each added tag turns into a tag)
  #   - [x] Persist tags
  #   - [x] Erase input tag content when removing tag and adding tag
  # - [ ] Add a curriculum input
  #   - [ ] Add curriculum cycle 2 maths
  #   - [ ] Register curriculum in Meilisearch
  #   - [ ] Relation has many curriculum
  #   - [ ] Auto complete input.
  #   - [ ] Auto complete input.

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
        <.curriculum_input curriculum={@curriculum} autocomplete={@curriculum_autocomplete} />
        <.tag_input tags={@tags} autocomplete_tags={@autocomplete_tags} tag={@tag_input} />
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

  def curriculum_input(assigns) do
    ~H"""
    <div class="fieldset">
      <label for="curriculum" class="static">
        <span class="label mb-1">{gettext("Curriculum")}</span>
        <input
          type="text"
          id="curriculum"
          name="curriculum"
          value={@curriculum}
          class="w-full input"
          phx-change="curriculum-complete"
        />
        <div
          :if={@autocomplete != []}
          class="flex flex-col gap-2 border-2 absolute rounded-md z-10"
        >
          <ul class="list bg-base-100 rounded-box shadow-md">
            <li
              :for={entry <- @autocomplete}
              class="list-row hover:bg-primary"
              phx-click="set-curriculum"
              phx-value-curriculum={entry}
            >
              {entry}
            </li>
          </ul>
        </div>
      </label>
    </div>
    """
  end

  attr :tags, :string, default: ""
  attr :autocomplete_tags, :list, default: []
  attr :tag, :string, default: ""

  def tag_input(assigns) do
    tags_list =
      case assigns.tags do
        nil ->
          []

        _ ->
          TeacherCoop.Tags.get_tags_from_indexes(String.split(assigns.tags, " ", trim: true))
      end

    assigns = assign(assigns, :tags_list, tags_list)

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
        />
        <div
          :if={@autocomplete_tags != []}
          class="flex flex-col gap-2 border-2 absolute rounded-md z-10"
        >
          <ul class="list bg-base-100 rounded-box shadow-md">
            <li
              :for={tag <- @autocomplete_tags}
              class="list-row hover:bg-primary"
              phx-click="add-tag"
              phx-value-tag={tag}
            >
              {tag}
            </li>
          </ul>
        </div>
        <div class="flex flex-row gap-4 m-4">
          <article
            :for={tag <- @tags_list}
            class="badge badge-soft badge-lg badge-primary hover:badge-accent relative group"
          >
            {tag}
            <div
              class="hidden btn btn-circle btn-xs absolute -right-2 -top-2 group-hover:flex"
              phx-click="remove-tag"
              phx-value-tag={tag}
            >
              X
            </div>
          </article>
        </div>
      </label>
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
      aria-label="cancel"
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
     |> allow_upload(:files, accept: ~w(.docx .pdf .txt .jpg .jpeg .png), max_entries: 10)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    document = Workspace.get_document!(socket.assigns.current_scope, id)
    files = Workspace.get_files(document.id)
    tags = if document.tags == nil, do: "", else: document.tags

    socket
    |> assign(:page_title, gettext("Edit Document"))
    |> assign(:document, document)
    |> assign(:files, files)
    |> assign(:tag_input, "")
    |> assign(:tags, tags)
    |> assign(:autocomplete_tags, [])
    |> assign(:curriculum, "")
    |> assign(:curriculum_autocomplete, [])
    |> assign(:form, to_form(Workspace.change_document(socket.assigns.current_scope, document)))
  end

  defp apply_action(socket, :new, _params) do
    document = %Document{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, gettext("New Document"))
    |> assign(:document, document)
    |> assign(:tag_input, "")
    |> assign(:tags, "")
    |> assign(:curriculum, "")
    |> assign(:curriculum_autocomplete, [])
    |> assign(:autocomplete_tags, [])
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
    current_tags =
      TeacherCoop.Tags.get_tags_from_indexes(String.split(socket.assigns.tags, " ", trim: true))

    autocomplete_tags =
      Workspace.autocomplete_tags(tag)
      |> Enum.filter(fn entry -> !Enum.any?(current_tags, fn tag -> tag == entry end) end)

    {:noreply, assign(socket, :autocomplete_tags, autocomplete_tags)}
  end

  def handle_event("add-tag", %{"tag" => tag}, socket) do
    index = TeacherCoop.Tags.get_index_from_value(tag)
    tags = socket.assigns.tags <> " " <> Integer.to_string(index)

    {:noreply,
     assign(socket, :tags, tags)
     |> assign(:autocomplete_tags, [])
     |> assign(:tag_input, "")}
  end

  def handle_event("remove-tag", %{"tag" => tag}, socket) do
    index = TeacherCoop.Tags.get_index_from_value(tag)
    tags = String.replace(socket.assigns.tags, Integer.to_string(index), "")

    {:noreply,
     assign(socket, :tags, tags)
     |> assign(:autocomplete_tags, [])
     |> assign(:tag_input, "")}
  end

  # Event Curriculum Input *************************************************************
  def handle_event("set-curriculum", %{"curriculum" => curriculum}, socket) do
    assign(socket, :curriculum, curriculum)
  end

  def handle_event("curriculum-complete", %{"curriculum" => curriculum}, socket)
      when byte_size(curriculum) > 3 do
    IO.puts(curriculum)
    {:noreply, assign(socket, :autocomplete_curriculum, [curriculum])}
  end

  def handle_event("curriculum-complete", %{"curriculum" => curriculum}, socket) do
    {:noreply, socket}
  end

  # Event Form save *************************************************************
  def handle_event("save", %{"document" => document_params}, socket) do
    files = get_files_from_uploads(socket)
    document_params = Map.put(document_params, "tags", String.trim(socket.assigns.tags))
    IO.inspect(document_params)
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
end

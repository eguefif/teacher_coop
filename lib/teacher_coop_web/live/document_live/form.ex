defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace
  alias TeacherCoop.Workspace.Document

  # TODO:
  # - [x] Display one file error correctly
  # - [x] Persist document (description)
  # - [x] Persist files
  # - [x] Update edit form.
  # - [ ] Add a document type
  # - [ ] Add a the curriculum

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

  attr :files, :list, required: true

  def files_list(assigns) do
    ~H"""
    <h2>{gettext("Files")}</h2>
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
    files = Workspace.get_files!(document.id)

    socket
    |> assign(:page_title, gettext("Edit Document"))
    |> assign(:document, document)
    |> assign(:files, files)
    |> assign(:form, to_form(Workspace.change_document(socket.assigns.current_scope, document)))
  end

  defp apply_action(socket, :new, _params) do
    document = %Document{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, gettext("New Document"))
    |> assign(:document, document)
    |> assign(:form, to_form(Workspace.change_document(socket.assigns.current_scope, document)))
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("remove-file", %{"id" => id}, socket) do
    Workspace.delete_file!(id)
    files = Workspace.get_files!(socket.assigns.document.id)
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

  def handle_event("save", %{"document" => document_params}, socket) do
    files = get_files_from_uploads(socket)
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

  # File uploads Error Handling
  defp error_to_string(:too_many_files), do: gettext("You added too many files.")
  defp error_to_string(:too_large), do: gettext("File too large.")
  defp error_to_string(:not_accepted), do: gettext("This file format is not accepted.")
end

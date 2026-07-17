defmodule TeacherCoopWeb.DocumentLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Library
  alias TeacherCoop.Library.Document
  alias TeacherCoop.Curriculum

  # TODO: 
  # - [ ] Handles objectives
  #   - [ ] Add a join table for objectives between document and objectives
  #   - [ ] Handle delete add new objectives in edit mode

  @max_files 2
  @formats ~w(.docx .pdf .txt .xlsx)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="document-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:title]}
          type="text"
          label={gettext("titre") |> String.capitalize()}
          phx-debounce="blur"
        />
        <.input
          field={@form[:description]}
          type="text"
          label={gettext("description") |> String.capitalize()}
          phx-debounce="blur"
        />
        <.input
          field={@form[:institution_type]}
          type="select"
          label={gettext("institution type") |> String.capitalize()}
          options={
            TeacherCoop.Library.Document.institution_types_options() |> Enum.map(&String.capitalize/1)
          }
        />
        <.input
          field={@form[:grade]}
          type="select"
          label={gettext("grade") |> String.capitalize()}
          options={TeacherCoop.Library.Document.grades_options()}
        />
        <.objectives_autocomplete_input
          objective_results={@objective_results}
          show_objective_results={@show_objective_results}
        />
        <.selected_objectives_view objectives={@selected_objectives} />

        <!-- File selection Input -->
        <div
          phx-drop-target={@uploads.files.ref}
          class={[
            "border-2 border-dashed rounded-lg p-6 mb-4 cursor-pointer",
            @uploads.files.errors == [] && "border-gray-300",
            @uploads.files.errors != [] && "border-error"
          ]}
        >
          <label
            for={@uploads.files.ref}
            class="block text-sm font-medium cursor-pointer mb-2"
          >
            <div :if={Enum.all?(@uploads.files.errors, &(elem(&1, 1) != :too_many_files)) == true}>
              {gettext("Upload files") <> "(maximum: #{@max_files})"}
            </div>
            <div
              :if={Enum.any?(@uploads.files.errors, &(elem(&1, 1) == :too_many_files)) == true}
              class="text-error"
            >
              {gettext("Too many files. Maximum is ")} {"#{@max_files}"}
            </div>
          </label>
          <.live_file_input upload={@uploads.files} />
        </div>
        <.display_files
          uploads={@uploads}
          files={@current_document_files}
          files_to_delete={@files_to_delete}
        />
        <footer>
          <.button phx-disable-with={gettext("Saving...")} variant="primary">{gettext("Save")} {gettext(
            "Document"
          )}</.button>
          <.button navigate={return_path(@current_scope, @return_to, @document)}>{gettext("Cancel")}</.button>
        </footer>
      </.form>
      <pre><%= inspect assigns.uploads, pretty: true %></pre>
    </Layouts.app>
    """
  end

  attr :objective_results, :list, default: []
  attr :show_objective_results, :boolean, default: false

  def objectives_autocomplete_input(assigns) do
    ~H"""
    <div phx-click-away={
      JS.dispatch("objectives_input:clear", to: "#objectives_input")
      |> JS.push("reset-objective-results")
    }>
      <.input
        id="objectives_input"
        name="objectives_input"
        type="text"
        phx-focus="user-focus-objectives-input"
        phx-hook=".ClearObjectivesInput"
        value=""
        label={gettext("objectives") |> String.capitalize()}
      />
      <script :type={Phoenix.LiveView.ColocatedHook} name=".ClearObjectivesInput">
        export default {
          mounted() {
            this.el.addEventListener("objectives_input:clear", (e) => {
            e.target.value = ""
            e.target.dispatchEvent(new Event("input", {bubles: true}))
            })
          }
        }
      </script>
      <div :if={@objective_results != [] && @show_objective_results} class="relative">
        <ul class="list absolute rounded-box shadow-md bg-base-200 max-h-150 overflow-auto z-2">
          <li
            :for={result <- @objective_results}
            class="list-row hover:bg-base-100"
            phx-click={
              JS.dispatch("objectives_input:clear", to: "#objectives_input")
              |> JS.push("select-objective")
            }
            phx-value-id={result["id"]}
          >
            {result["goal"]}
          </li>
        </ul>
      </div>
    </div>
    """
  end

  attr :objectives, :list, default: []

  def selected_objectives_view(assigns) do
    ~H"""
    <div :if={@objectives != []}>
      <ul class="list">
        <li
          :for={objective <- @objectives}
          class="list-row"
        >
          <span
            phx-click={
              JS.dispatch("objectives_input:clear", to: "#objectives_input")
              |> JS.push("remove-objective")
            }
            phx-value-id={objective["id"]}
          >
            <.icon
              name="hero-x-mark"
              class="scale-90 hover:scale-115 transition-transform ease-in-out duration-200 cursor-pointer"
            />
          </span>
          {objective["goal"]}
        </li>
      </ul>
    </div>
    """
  end

  attr :uploads, :list, default: []
  attr :files, :list, default: []
  attr :files_to_delete, :list, default: []

  def display_files(assigns) do
    ~H"""
    <div>
      <div :if={@files != nil && @files != []}>
        <div
          :for={file <- @files}
          class={[
            "px-4 py-3 rounded mb-4 flex flex-row justify-between content-successline",
            file.id in (Enum.map(@files, & &1.id) -- @files_to_delete) &&
              "bg-success/30 border border-success/70 text-success/100",
            file.id in @files_to_delete && "bg-warning/30 border border-warning/70 text-warning/100"
          ]}
        >
          <div>{file.filename}</div>
          <div
            :if={file.id in (Enum.map(@files, & &1.id) -- @files_to_delete)}
            phx-click="delete-file"
            phx-value-file-id={file.id}
          >
            <.icon
              name="hero-x-mark"
              class="size-6 scale-100 hover:scale-120 transition-scale ease-in-out cursor-pointer"
            />
          </div>

          <div
            :if={file.id in @files_to_delete}
            phx-click="restore-file"
            phx-value-file-id={file.id}
          >
            <.icon
              name="hero-arrow-uturn-down"
              class="size-6 scale-100 hover:scale-120 transition-scale ease-in-out cursor-pointer"
            />
          </div>
        </div>
      </div>

      <div :if={@uploads.files.entries != []}>
        <div>{gettext("New file")}</div>
        <.new_file_row
          :for={file <- @uploads.files.entries}
          file={file}
          error={
            Enum.filter(@uploads.files.errors, &(elem(&1, 0) == file.ref))
            |> Enum.map(&error_to_string(elem(&1, 1)))
            |> Enum.at(0)
          }
        />
      </div>
    </div>
    """
  end

  attr :file, :map, default: %{}
  attr :error, :string, default: nil

  def new_file_row(assigns) do
    ~H"""
    <div class={[
      "px-4 py-3 rounded mb-4 flex flex-row justify-between content-baseline",
      @error == nil && "bg-info/30 border border-info/70 text-info/100 ",
      @error != nil && "bg-error/30 border border-error/70 text-error/100"
    ]}>
      <div>
        <span :if={@error != nil} class="text-lg text-bold mr-4">
          {@error}
        </span>
        <span>
          {@file.client_name} -
        </span>
        <span :if={@error == nil}>
          {@file.progress}%
        </span>
      </div>
      <div
        phx-click="remove-file"
        phx-value-ref={@file.ref}
      >
        <.icon
          name="hero-x-mark"
          class="size-6 scale-100 hover:scale-120 transition-scale ease-in-out cursor-pointer"
        />
      </div>
    </div>
    """
  end

  defp error_to_string(error) when is_atom(error) do
    case error do
      :too_large -> gettext("File too large")
      :not_accepted -> gettext("Wrong format, must be one of ") <> Enum.join(@formats)
      value -> Atom.to_string(value)
    end
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:selected_objectives, [])
     |> assign(:files_to_delete, [])
     |> assign(:show_objective_results, false)
     |> assign(:max_files, @max_files)
     |> allow_upload(:files,
       accept: @formats,
       max_entries: @max_files,
       max_file_size: 300_000,
       auto_upload: false
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    document = Library.get_document!(id)

    socket
    |> assign(:page_title, "Edit Document")
    |> assign(:document, document)
    |> assign(:current_document_files, document.files)
    |> assign(:objective_results, document.objectives)
    |> assign(:form, to_form(Library.change_document(socket.assigns.current_scope, document)))
  end

  defp apply_action(socket, :new, _params) do
    document = %Document{user_id: socket.assigns.current_scope.user.id, files: []}

    socket
    |> assign(:page_title, "New Document")
    |> assign(:objective_results, [])
    |> assign(:current_document_files, [])
    |> assign(:document, document)
    |> assign(:form, to_form(Library.change_document(socket.assigns.current_scope, document)))
  end

  @impl true
  def handle_event(
        "validate",
        %{"document" => document_params, "objectives_input" => objectives_input},
        socket
      ) do
    document_params =
      Map.put(document_params, "objectives", socket.assigns.selected_objectives)

    changeset =
      Library.change_document(
        socket.assigns.current_scope,
        socket.assigns.document,
        document_params
      )

    {objective_results, show_objective_results} =
      if String.length(objectives_input) >= 3 do
        {Curriculum.search_objectives(objectives_input), true}
      else
        {[], false}
      end

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate))
     |> assign(:objective_results, objective_results)
     |> assign(:show_objective_results, show_objective_results)}
  end

  def handle_event("reset-objective-results", _, socket) do
    {:noreply, socket |> assign(:objective_results, []) |> assign(:show_objective_results, false)}
  end

  def handle_event("user-focus-objectives-input", _, socket) do
    {:noreply, socket |> assign(:show_objective_results, true)}
  end

  def handle_event("select-objective", %{"id" => id}, socket) do
    id = String.to_integer(id)

    objective =
      Enum.find(socket.assigns.objective_results, fn objective -> objective["id"] == id end)

    {:noreply,
     socket
     |> assign(:selected_objectives, [objective | socket.assigns.selected_objectives])
     |> assign(:objective_results, [])
     |> assign(:show_objective_results, false)}
  end

  def handle_event("remove-file", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  def handle_event("delete-file", %{"file-id" => file_id}, socket) do
    {:noreply,
     update(socket, :files_to_delete, fn files -> [String.to_integer(file_id) | files] end)}
  end

  def handle_event("restore-file", %{"file-id" => file_id}, socket) do
    {:noreply, update(socket, :files_to_delete, fn files -> [file_id] -- files end)}
  end

  def handle_event("remove-objective", %{"id" => id}, socket) do
    id = String.to_integer(id)

    objectives =
      Enum.reject(socket.assigns.selected_objectives, fn objective -> objective["id"] == id end)

    {:noreply,
     socket
     |> assign(:selected_objectives, objectives)
     |> assign(:show_objective_results, false)}
  end

  def handle_event("save", %{"document" => document_params}, socket) do
    document_params =
      if socket.assigns.selected_objectives != [] do
        Map.put(document_params, "objectives", socket.assigns.selected_objectives)
      else
        document_params
      end

    save_document(socket, socket.assigns.live_action, document_params)
  end

  defp save_document(socket, :edit, document_params) do
    document_params = params_with_files(socket, document_params)

    case Library.update_document(
           socket.assigns.current_scope,
           socket.assigns.document,
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

  defp save_document(socket, :new, document_params) do
    document_params = Map.put(document_params, "files", [])
    document_params = params_with_files(socket, document_params)

    case Library.create_document(socket.assigns.current_scope, document_params) do
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

  defp params_with_files(socket, document_params) do
    existing_files =
      socket.assigns.current_document_files
      |> Enum.reject(fn file -> file.id in socket.assigns.files_to_delete end)
      |> Enum.map(&Map.take(&1, [:id, :filename, :filepath, :format]))

    files =
      socket
      |> consume_uploaded_entries(:files, &upload_static_file/2)
      |> Enum.map(fn %{filename: filename, filepath: filepath} ->
        format = Path.extname(filename) |> String.slice(1..-1//1)
        %{"filename" => filename, "filepath" => filepath, "format" => format}
      end)

    Map.put(document_params, "files", files ++ existing_files)
  end

  defp upload_static_file(%{path: path}, entry) do
    filename = Path.basename(path)
    filepath = Path.join("priv/static/files", filename)
    File.cp!(path, filepath)

    {:ok, %{filename: entry.client_name, filepath: "/files/#{filename}"}}
  end

  defp return_path(_scope, "index", _document), do: ~p"/documents"
  defp return_path(_scope, "show", document), do: ~p"/documents/#{document}"
end

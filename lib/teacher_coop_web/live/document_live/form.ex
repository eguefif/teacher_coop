defmodule TeacherCoopWeb.DocumentLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Library
  alias TeacherCoop.Library.Document
  alias TeacherCoop.Curriculum

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="document-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label={gettext("titre") |> String.capitalize()} />
        <.input
          field={@form[:description]}
          type="text"
          label={gettext("description") |> String.capitalize()}
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
        <footer>
          <.button phx-disable-with={gettext("Saving...")} variant="primary">{gettext("Save")} {gettext(
            "Document"
          )}</.button>
          <.button navigate={return_path(@current_scope, @return_to, @document)}>{gettext("Cancel")}</.button>
        </footer>
      </.form>
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

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:objective_results, [])
     |> assign(:selected_objectives, [])
     |> assign(:show_objective_results, false)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    document = Library.get_document!(id)

    socket
    |> assign(:page_title, "Edit Document")
    |> assign(:document, document)
    |> assign(:form, to_form(Library.change_document(socket.assigns.current_scope, document)))
  end

  defp apply_action(socket, :new, _params) do
    document = %Document{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Document")
    |> assign(:document, document)
    |> assign(:form, to_form(Library.change_document(socket.assigns.current_scope, document)))
  end

  @impl true
  def handle_event(
        "validate",
        %{"document" => document_params, "objectives_input" => objectives_input},
        socket
      ) do
    document_params = Map.put(document_params, "objectives", socket.assigns.selected_objectives)

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

  defp return_path(_scope, "index", _document), do: ~p"/documents"
  defp return_path(_scope, "show", document), do: ~p"/documents/#{document}"
end

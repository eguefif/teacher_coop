defmodule TeacherCoopWeb.DocumentLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Library
  alias TeacherCoop.Library.Document

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
        <.input
          field={@form[:objectives]}
          type="text"
          label={gettext("objectives") |> String.capitalize()}
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">{gettext("Save")} {gettext(
            "Document"
          )}</.button>
          <.button navigate={return_path(@current_scope, @return_to, @document)}>{gettext("Cancel")}</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
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
  def handle_event("validate", %{"document" => document_params}, socket) do
    changeset =
      Library.change_document(
        socket.assigns.current_scope,
        socket.assigns.document,
        document_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"document" => document_params}, socket) do
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

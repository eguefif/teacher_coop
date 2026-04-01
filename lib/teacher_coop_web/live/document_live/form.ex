defmodule TeacherCoopWeb.WorkspaceLive.DocumentLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace
  alias TeacherCoop.Workspace.Document

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="document-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <footer>
          <.button phx-disable-with={gettext("Saving...")} variant="primary">Save Document</.button>
          <.button navigate={return_path(@current_scope, @return_to, @document)}>Cancel</.button>
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
    document = Workspace.get_document!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, gettext("Edit Document"))
    |> assign(:document, document)
    |> assign(:form, to_form(Workspace.change_document(socket.assigns.current_scope, document)))
  end

  defp apply_action(socket, :new, _params) do
    document = %Document{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, gettext("New Document"))
    |> assign(:document, document)
    |> assign(:form, to_form(Workspace.change_document(socket.assigns.current_scope, document)))
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
    save_document(socket, socket.assigns.live_action, document_params)
  end

  defp save_document(socket, :edit, document_params) do
    case Workspace.update_document(
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
    case Workspace.create_document(socket.assigns.current_scope, document_params) do
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
  defp return_path(_scope, "show", document), do: ~p"/workspace/documents/#{document}"
end

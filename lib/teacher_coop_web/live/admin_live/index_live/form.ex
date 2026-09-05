defmodule TeacherCoopWeb.AdminLive.IndexLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Discovery.Configuration
  alias TeacherCoop.Discovery.Configuration.Index

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>
      <.form for={@form} id="index-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:uid]} type="text" label="Title" />
        <.input
          type="select"
          field={@form[:engine_configuration_id]}
          options={[{gettext("None"), ""} | Enum.map(@configurations, &{&1.name, &1.id})]}
          label={gettext("Engine Configuration")}
        />
        <footer>
          <.button phx-disable-with={gettext("Saving...")} variant="primary">{gettext("Save index")}</.button>
          <.button navigate={return_path(@return_to, @index)}>{gettext("Cancel")}"</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    configurations = Configuration.list_configurations(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:configurations, configurations)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    current_scope = socket.assigns.current_scope

    index = Configuration.get_index!(id, current_scope)

    socket
    |> assign(:page_title, gettext("Edit") <> " " <> gettext("Index"))
    |> assign(:index, index)
    |> assign(:form, to_form(Configuration.change_index(current_scope, index)))
  end

  defp apply_action(socket, :new, _params) do
    current_scope = socket.assigns.current_scope
    index = %Index{}

    socket
    |> assign(:page_title, gettext("New") <> " " <> gettext("Index"))
    |> assign(:index, index)
    |> assign(:form, to_form(Configuration.change_index(current_scope, index)))
  end

  @impl true
  def handle_event("validate", %{"index" => index_params}, socket) do
    changeset =
      Configuration.change_index(socket.assigns.current_scope, socket.assigns.index, index_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"index" => index_params}, socket) do
    save_index(socket, socket.assigns.live_action, index_params)
  end

  defp save_index(socket, :edit, index_params) do
    case Configuration.update_index(
           socket.assigns.index,
           index_params,
           socket.assigns.current_scope
         ) do
      {:ok, index} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Index updated successfully"))
         |> push_navigate(to: return_path(socket.assigns.return_to, index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_index(socket, :new, index_params) do
    case Configuration.create_index(index_params, socket.assigns.current_scope) do
      {:ok, index} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Index created successfully"))
         |> push_navigate(to: return_path(socket.assigns.return_to, index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _index), do: ~p"/admin/indexes"
  defp return_path("show", index), do: ~p"/admin/indexes/#{index}"
  defp return_path(_, index), do: ~p"/admin/indexes/#{index}"
end

defmodule TeacherCoopWeb.WorkspaceLive.GroupLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Workspace.Groups
  alias TeacherCoop.Workspace.Groups.WorkingGroup

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>
      <.form
        for={@form}
        id="group-form"
        phx-change="validate"
        phx-submit="save"
        class="flex flex-col gap-4"
      >
        <.input
          field={@form[:name]}
          type="text"
          label={gettext("Group name")}
        />
        <footer class="mx-auto">
          <.button phx-disable-with={gettext("Saving...")} variant="primary">
            {gettext("Save Group")}
          </.button>
          <.button navigate={return_path(@current_scope, @return_to, @group)}>
            {gettext("Cancel")}
          </.button>
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

  defp apply_action(socket, :new, _params) do
    group = %WorkingGroup{}

    socket
    |> assign(:page_title, gettext("New Group"))
    |> assign(:group, group)
    |> assign(:form, to_form(Groups.change_group(group)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    group = Groups.get_group!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, gettext("Edit Group"))
    |> assign(:group, group)
    |> assign(:form, to_form(Groups.change_group(group)))
  end

  defp return_path(_scope, "index", _group), do: ~p"/workspace/groups"
  defp return_path(_scope, "show", group), do: ~p"/workspace/groups/#{group.id}"

  # Event Group *********************************************
  @impl true
  def handle_event("validate", %{"working_group" => group_params}, socket) do
    {:noreply,
     assign(socket, :form, to_form(Groups.change_group(socket.assigns.group, group_params)))}
  end

  def handle_event("save", %{"working_group" => group_params}, socket) do
    save_group(socket, socket.assigns.live_action, group_params)
  end

  def save_group(socket, :new, group_params) do
    case Groups.create_group(socket.assigns.current_scope, group_params) do
      {:ok, group} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Group created successfully"))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, group)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          socket |> assign(socket, form: to_form(changeset))
        }
    end
  end

  def save_group(socket, :edit, group_params) do
    case Groups.update_group(socket.assigns.current_scope, socket.assigns.group, group_params) do
      {:ok, group} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Group updated successfully"))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, group)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          socket |> assign(socket, form: to_form(changeset))
        }
    end
  end
end

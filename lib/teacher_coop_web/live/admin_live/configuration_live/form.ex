defmodule TeacherCoopWeb.AdminLive.ConfigurationLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Discovery.Configuration
  alias TeacherCoop.Discovery.Configuration.EngineConfiguration

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="configuration-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:index_name]}
          type="text"
          label={gettext("Index Name")}
          phx-debounce="blur"
        />
        <.input
          field={@form[:engine]}
          type="text"
          label={gettext("Engine Name")}
          phx-debounce="blur"
        />
        <.input
          field={@form[:filterable_attributes]}
          type="text"
          label={gettext("Filterables Attributes (comma separated list)")}
          placeholder={gettext("user_id, grade")}
          phx-debounce="blur"
        />
        <footer>
          <.button phx-disable-with={gettext("Saving...")} variant="primary">{gettext("Save")} {gettext(
            "Document"
          )}</.button>
          <.button navigate={return_path(@current_scope, @return_to, @configuration)}>{gettext(
            "Cancel"
          )}</.button>
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

  def apply_action(socket, :edit, %{"id" => id}) do
    configuration = Configuration.get_configuration!(String.to_integer(id))

    changeset =
      Configuration.change_configuration(
        socket.assigns.current_scope,
        configuration
      )

    socket
    |> assign(:page_title, gettext("New") <> " " <> gettext("Configuration"))
    |> assign(:form, to_form(changeset))
    |> assign(:configuration, configuration)
  end

  def apply_action(socket, :new, _params) do
    configuration = %EngineConfiguration{
      user_id: socket.assigns.current_scope.user.id,
      engine: "meilisearch"
    }

    socket
    |> assign(:page_title, gettext("Edit") <> " " <> gettext("Configuration"))
    |> assign(
      :form,
      to_form(
        Configuration.change_configuration(
          socket.assigns.current_scope,
          configuration
        )
      )
    )
    |> assign(:configuration, configuration)
  end

  @impl true
  def handle_event("validate", %{"engine_configuration" => configuration_params}, socket) do
    IO.inspect(configuration_params)
    configuration_params = create_config(configuration_params)

    changeset =
      Configuration.change_configuration(
        socket.assigns.current_scope,
        socket.assigns.configuration,
        configuration_params
      )

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"engine_configuration" => configuration_params}, socket) do
    save_document(socket, socket.assigns.live_action, configuration_params)
  end

  def save_document(socket, :new, configuration_params) do
    result =
      Configuration.create_configuration(socket.assigns.current_scope, configuration_params)

    case result do
      {:ok, configuration} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Configuration created successfully"))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, configuration)
         )}

      {:error, changeset} ->
        {:noreply, socket |> assign(:form, to_form(changeset))}
    end
  end

  defp create_config(configuration_params) do
    {%{}, configuration_params}
    |> add_filterable_attributes()
    |> put_config()
  end

  defp put_config({config, configuration_params}) do
    Map.put(configuration_params, "config", config)
  end

  defp add_filterable_attributes({config, configuration_params}) do
    attributes =
      configuration_params["filterable_attributes"]
      |> String.split(",")
      |> Enum.map(&String.trim(&1))

    configuration_params = Map.delete(configuration_params, :filterable_attributes)

    {config |> Map.put(:filterable_attributes, attributes), configuration_params}
  end

  defp return_path(_scope, "index", _document), do: ~p"/admin/configuration"
  defp return_path(_scope, "show", document), do: ~p"/admin/configuration/#{document}"
end

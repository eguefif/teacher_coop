defmodule TeacherCoopWeb.AdminLive.ConfigurationLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Discovery.Configuration
  alias TeacherCoop.Discovery.Configuration.EngineConfiguration
  alias TeacherCoop.Discovery.Configuration.EngineConfiguration.{Config, Config.Embedder}

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
        <div class="divider w-[25%] mx-auto"></div>
        <.inputs_for :let={config_form} field={@form[:config]}>
          <.input
            type="text"
            field={config_form[:filterable_attributes]}
            label={gettext("Filterable Attributes")}
            placeholder={gettext("user_id, grade")}
            phx-debounce="blur"
          />
          <.embedders_input field={config_form[:embedders]} />
        </.inputs_for>
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

  attr :field, Phoenix.HTML.FormField, required: true

  defp embedders_input(assigns) do
    ~H"""
    <fieldset class="fieldset mt-2">
      <legend class="fieldset-legend text-base">{gettext("Embedders")}</legend>

      <div class="flex flex-col gap-4">
        <.inputs_for :let={embedders_form} field={@field}>
          <div class="card card-border bg-base-100 border-base-300">
            <div class="card-body gap-3 p-4">
              <input type="hidden" name="embedders[embedders_sort][]" value={embedders_form.index} />
              <div class="flex items-start justify-between gap-4">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-4 flex-1">
                  <.input
                    type="text"
                    field={embedders_form[:name]}
                    label={gettext("Name")}
                    placeholder={gettext("default")}
                    phx-debounce="blur"
                  />
                  <.input
                    type="text"
                    field={embedders_form[:model]}
                    label={gettext("Model")}
                    placeholder="text-embedding-3-small"
                    phx-debounce="blur"
                  />
                </div>
                <button
                  type="button"
                  name="embedders[embedders_drop][]"
                  value={embedders_form.index}
                  class="btn btn-ghost btn-square btn-sm mt-6"
                  aria-label={gettext("Remove embedder")}
                  phx-click={JS.dispatch("change")}
                >
                  <.icon name="hero-x-mark" class="w-5 h-5" />
                </button>
              </div>
              <.input
                type="text"
                field={embedders_form[:template]}
                label={gettext("Template")}
                placeholder={gettext("{{document.title}} for {{document.grade}} students")}
                phx-debounce="blur"
              />
            </div>
          </div>
        </.inputs_for>

        <input type="hidden" name="embedders[embedders_drop][]" />
        <button
          type="button"
          name="embedders[embedders_sort][]"
          class="btn btn-outline btn-primary btn-sm self-start"
          value="new"
          phx-click={JS.dispatch("change")}
        >
          <.icon name="hero-plus" class="w-4 h-4" /> {gettext("Add more embedders")}
        </button>
      </div>
    </fieldset>
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
      engine: "meilisearch",
      config: %Config{
        embedders: [
          %Config.Embedder{name: "default", source: "huggingFace", model: "", template: ""}
        ]
      }
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
    configuration_params = create_config(configuration_params)
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
    configuration_params
    |> add_filterable_attributes()

    # |> add_embedders()
  end

  defp add_filterable_attributes(configuration_params) do
    Kernel.get_and_update_in(
      configuration_params,
      ["config", "filterable_attributes"],
      fn attrs ->
        {attrs,
         attrs
         |> String.split(",")
         |> Enum.map(&String.trim(&1))}
      end
    )
    |> elem(1)
  end

  defp add_embedders({config, configuration_params}) do
    model = configuration_params["embedders_model"]
    template = configuration_params["embedders_template"]

    configuration_params =
      Map.delete(configuration_params, "embedders_model")
      |> Map.delete("embedders_template")

    embedders = [
      %{"name" => "default", "source" => "huggingFace", "model" => model, "template" => template}
    ]

    {config |> Map.put("embedders", embedders), configuration_params}
  end

  defp return_path(_scope, "index", _document), do: ~p"/admin/configuration"
  defp return_path(_scope, "show", document), do: ~p"/admin/configuration/#{document}"
end

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
          field={@form[:name]}
          type="text"
          label={gettext("Configuration Name")}
          phx-debounce="blur"
        />
        <.input
          field={@form[:index_names]}
          type="select"
          label={gettext("Index Name")}
          options={@index_names_options}
          multiple={true}
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
            type="checkbox"
            field={config_form[:facet_search]}
            label={gettext("Facet Search")}
            phx-debounce="blur"
          />
          <.input
            type="select"
            options={[gettext("None") | @field_options]}
            field={config_form[:distinct_attribute]}
            label={gettext("Distinct Attributes")}
            phx-debounce="blur"
          />
          <.input
            type="select"
            multiple
            options={@field_options}
            field={config_form[:filterable_attributes]}
            label={gettext("Filterable Attributes")}
            class="flex flex-row flex-wrap gap-2 w-full select"
            phx-debounce="blur"
          />
          <.input
            type="select"
            options={EngineConfiguration.get_proximity_precision_values()}
            field={config_form[:proximity_precision]}
            label={gettext("Proximity_precision")}
            phx-debounce="blur"
          />
          <.input
            type="select"
            multiple
            options={@field_options}
            field={config_form[:searchable_attributes]}
            class="flex flex-row flex-wrap gap-2 w-full select"
            label={gettext("Searchable Attributes")}
            phx-debounce="blur"
          />
          <.input
            type="select"
            multiple
            options={@field_options}
            field={config_form[:sortable_attributes]}
            class="flex flex-row flex-wrap gap-2 w-full select"
            label={gettext("Sortable Attributes")}
            phx-debounce="blur"
          />
          <.input
            type="text"
            field={config_form[:stop_words]}
            value={words_to_str(config_form[:stop_words].value)}
            placeholder={gettext("la le li")}
            label={gettext("Stop Words")}
            phx-debounce="blur"
          />
          <.input
            type="text"
            field={config_form[:separator_tokens]}
            value={words_to_str(config_form[:separator_tokens].value)}
            placeholder={gettext("|")}
            label={gettext("Separator Tokens")}
            phx-debounce="blur"
          />
          <.input
            type="text"
            field={config_form[:non_separator_tokens]}
            value={words_to_str(config_form[:non_separtor_tokens].value)}
            placeholder={gettext("@ ")}
            label={gettext("Non Separator Tokens")}
            phx-debounce="blur"
          />
          <.input
            type="text"
            field={config_form[:ranking_rules]}
            value={words_to_str(config_form[:ranking_rules].value)}
            label={gettext("Ranking Rules") <>  " (#{words_to_str(EngineConfiguration.get_ranking_rules())})"}
            phx-debounce="blur"
          />
          <.input
            type="text"
            field={config_form[:dictionary]}
            value={words_to_str(config_form[:dictionary].value)}
            placeholder={gettext("J.R.R")}
            label={gettext("Dictionary")}
            phx-debounce="blur"
          />
          <.embedder_input field={config_form[:embedders]} />
          <.typo_tolerance_input field={config_form[:typo_tolerance]} />
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

  def words_to_str(str) when is_binary(str), do: str
  def words_to_str(list) when is_list(list), do: Enum.join(list, " ")
  def words_to_str(_), do: ""

  attr :field, Phoenix.HTML.FormField, required: true

  defp embedder_input(assigns) do
    ~H"""
    <fieldset class="fieldset mt-2">
      <legend class="fieldset-legend text-base">{gettext("Embedder")}</legend>

      <div class="flex flex-col gap-4">
        <.inputs_for :let={embedder_form} field={@field}>
          <.inputs_for :let={default_embedder} field={embedder_form[:default]}>
            <div class="card card-border bg-base-100 border-base-300">
              <div class="card-body gap-3 p-4">
                <div class="flex items-start justify-between gap-4">
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-4 flex-1">
                    <.input
                      type="text"
                      field={default_embedder[:name]}
                      label={gettext("Name")}
                      placeholder={gettext("default")}
                      phx-debounce="blur"
                    />
                    <.input
                      type="text"
                      field={default_embedder[:model]}
                      label={gettext("Model")}
                      placeholder="text-embedding-3-small"
                      phx-debounce="blur"
                    />
                  </div>
                </div>
                <.input
                  type="text"
                  field={default_embedder[:document_template]}
                  label={gettext("Template")}
                  placeholder={gettext("{{document.title}} for {{document.grade}} students")}
                  phx-debounce="blur"
                />
              </div>
            </div>
          </.inputs_for>
        </.inputs_for>
      </div>
    </fieldset>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  def typo_tolerance_input(assigns) do
    ~H"""
    <fieldset class="fieldset mt-2">
      <legend class="fieldset-legend text-base">{gettext("Typo Tolerance")}</legend>

      <div class="flex flex-col gap-4">
        <.inputs_for :let={typo_tolerance} field={@field}>
          <div class="card card-body gap-3 p-4 card-border bg-base-100 border-base-300">
            <.input
              type="checkbox"
              field={typo_tolerance[:enabled]}
              label={gettext("Enabled")}
              phx-debounce="blur"
            />
            <.input
              type="text"
              field={typo_tolerance[:disable_on_words]}
              value={words_to_str(typo_tolerance[:disable_on_words])}
              label={gettext("Disable on words")}
              phx-debounce="blur"
            />
            <.inputs_for :let={min_word} field={typo_tolerance[:min_word_size_for_typos]}>
              <div class="flex flex-row gap-4">
                <.input
                  type="number"
                  field={min_word[:one_typo]}
                  label={gettext("Min word length to accept one typo")}
                  phx-debounce="blur"
                />
                <.input
                  type="number"
                  field={min_word[:two_typos]}
                  label={gettext("Min word length to accept two typos")}
                  phx-debounce="blur"
                />
              </div>
            </.inputs_for>
          </div>
        </.inputs_for>
      </div>
    </fieldset>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    scope = socket.assigns.current_scope
    index_names = Configuration.list_index(scope) |> Enum.map(& &1.name)

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:index_names_options, index_names)
     |> assign(:field_options, Configuration.list_index_fields(scope))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  def apply_action(socket, :edit, %{"id" => id}) do
    configuration =
      Configuration.get_configuration!(socket.assigns.current_scope, String.to_integer(id))

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

    configuration_changeset =
      Configuration.change_configuration(
        socket.assigns.current_scope,
        configuration
      )

    socket
    |> assign(:page_title, gettext("Edit") <> " " <> gettext("Configuration"))
    |> assign(
      :form,
      to_form(configuration_changeset)
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

  def save_document(socket, :edit, configuration_params) do
    result =
      Configuration.update_configuration(
        socket.assigns.current_scope,
        socket.assigns.configuration,
        configuration_params
      )

    case result do
      {:ok, configuration} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Configuration updated successfully"))
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, configuration)
         )}

      {:error, changeset} ->
        {:noreply, socket |> assign(:form, to_form(changeset))}
    end
  end

  defp create_config(configuration_params) do
    configuration_params
    |> Map.put_new("index_names", nil)
    |> Map.put_new("filterable_attributes", nil)
    |> Map.put_new("sortable_attributes", nil)
    |> Map.put_new("searchable_attributes", nil)
    |> handle_distinct_attribute()
    |> handle_multiwords_config(["config", "stop_words"])
    |> handle_multiwords_config(["config", "non_separator_tokens"])
    |> handle_multiwords_config(["config", "separator_tokens"])
    |> handle_multiwords_config(["config", "dictionary"])
    |> handle_multiwords_config(["config", "ranking_rules"])
    |> handle_typo_tolerance()

    # |> handle_embedder()
  end

  def handle_typo_tolerance(configuration_params) do
    get_and_update_in(
      configuration_params,
      ["config", "typo_tolerance"],
      fn attr ->
        {attr, handle_multiwords_config(attr, ["disable_on_words"])}
      end
    )
    |> elem(1)
  end

  def handle_distinct_attribute(configuration_params) do
    get_and_update_in(
      configuration_params,
      ["config", "distinct_attribute"],
      fn attr ->
        {attr,
         case attr do
           "None" -> nil
           value -> value
         end}
      end
    )
    |> elem(1)
  end

  def handle_multiwords_config(configuration_params, keys) do
    get_and_update_in(
      configuration_params,
      keys,
      fn attrs ->
        if is_binary(attrs) do
          {attrs, attrs |> String.split(" ", trim: true)}
        else
          {attrs, attrs}
        end
      end
    )
    |> elem(1)
  end

  defp return_path(_scope, "index", _document), do: ~p"/admin/configurations"
  defp return_path(_scope, "show", document), do: ~p"/admin/configurations/#{document}"
end

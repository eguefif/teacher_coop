defmodule TeacherCoopWeb.AdminLive.CurriculumLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Curriculum.CurriculumIngestion

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Ingest new subject")}
      </.header>

      <div class="w-full">
        <.form
          class="flex flex-col gap-4"
          for={@form}
          id="curriculum-form"
          phx-change="validate"
          phx-submit="ingest"
        >
          <.input
            id="year-input"
            field={@form[:year]}
            type="text"
            label={gettext("Curriculum Year")}
            phx-debounce="blur"
          />
          <fieldset class="fieldset">
            <label for={@uploads.file_content.ref} class="fieldset-legend">
              {gettext("Currifulum file")}
            </label>
            <.live_file_input
              upload={@uploads.file_content}
              class="file-input file-input-primary w-full"
            />
            <p class="label">{gettext("text file (.txt), max 2 MB")}</p>
          </fieldset>
          <div :if={@uploads.file_content.entries != []} class="flex flex-col gap-4">
            <div
              :for={file <- @uploads.file_content.entries}
              class={[
                "w-[296px] rounded-md p-[8px] flex flex-col gap-2",
                upload_errors(@uploads.file_content, file) == [] && "bg-info text-info-content",
                upload_errors(@uploads.file_content, file) != [] && "bg-error text-error-content"
              ]}
            >
              <div class="text-xl font-bold text-center">
                {file.client_name}
              </div>
              <p
                :for={err <- upload_errors(@uploads.file_content, file)}
                class="p-2 text-md"
              >
                {err}
              </p>
            </div>
          </div>

          <footer class="mx-auto mt-[32px]">
            <.button phx-disable-with={gettext("Ingesting...")} variant="primary">{gettext("Ingest")}</.button>
            <.button navigate={~p"/admin/curriculum"}>{gettext("Cancel")}</.button>
          </footer>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_scope, socket.assigns.current_scope)
     |> assign(:subjects, CurriculumIngestion.subjects())
     |> assign(:ingestion, %CurriculumIngestion{})
     |> allow_upload(:file_content,
       accept: ~w(.txt),
       max_entries: 20,
       max_file_size: 2_000_000,
       validator: fn entry ->
         filename = Path.basename(entry.client_name) |> String.split(".") |> Enum.at(0)
         subjects = CurriculumIngestion.subjects()

         if filename in subjects do
           :ok
         else
           {:error,
            gettext(
              "Filename should be build on the model `subject.txt` where subject is one of the following word: "
            ) <> Enum.join(subjects, ", ")}
         end
       end
     )
     |> assign(:form, to_form(CurriculumIngestion.changeset(%CurriculumIngestion{}, %{})))}
  end

  @impl true
  def handle_event("validate", %{"curriculum_ingestion" => ingestion_params}, socket) do
    ingestion_params =
      Map.put(
        ingestion_params,
        "subject",
        get_filename(socket.assigns.uploads.file_content.entries)
      )

    changeset = CurriculumIngestion.changeset(%CurriculumIngestion{}, ingestion_params)
    {:noreply, socket |> assign(form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("ingest", %{"curriculum_ingestion" => ingestion_params}, socket) do
    {ingestion_params, filecontent} = build_ingestion_params_from_files(ingestion_params, socket)
    scope = socket.assigns.current_scope

    case TeacherCoop.Curriculum.bulk_create_objectives_from_files(
           scope,
           ingestion_params,
           filecontent
         ) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Scheduled ingestion successfully"))
         |> push_navigate(to: ~p"/admin/curriculum")}

      {:error_changeset, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> put_flash(:error, gettext("Error in your form"))}

      {:error, reason} ->
        {:noreply,
         socket |> put_flash(:error, gettext("Error while scheduling ingestion task: ") <> reason)}
    end
  end

  defp build_ingestion_params_from_files(ingestion_params, socket) do
    filecontent = get_file_content(socket)

    filename = get_filename(socket.assigns.uploads.file_content.entries)

    ingestion_params =
      Map.put(ingestion_params, "subject", filename)
      |> Map.put("state", "created")

    {ingestion_params, filecontent}
  end

  defp get_filename(entries) when entries != [] do
    Enum.at(entries, 0)
    |> Map.get(:client_name)
    |> String.split(".")
    |> Enum.at(0)
  end

  defp get_filename(_), do: ""

  defp get_file_content(socket) do
    consume_uploaded_entries(socket, :file_content, fn %{path: path}, _ ->
      content = File.read!(path)
      {:ok, content}
    end)
    |> Enum.at(0)
  end
end

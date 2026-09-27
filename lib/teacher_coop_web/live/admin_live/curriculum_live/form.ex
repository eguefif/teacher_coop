defmodule TeacherCoopWeb.AdminLive.CurriculumLive.Form do
  use TeacherCoopWeb, :live_view

  alias TeacherCoop.Curriculum.Ingestion

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
            id="grade-input"
            field={@form[:grade]}
            type="select"
            options={@grade_options}
            label={gettext("Grade")}
            phx-debounce="blur"
          />
          <.input
            id="subject-input"
            field={@form[:subject]}
            type="select"
            options={@subject_options}
            label={gettext("Subject")}
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
            <p class="label">{gettext("text file (.txt), max 15 MB")}</p>
          </fieldset>
          <footer class="mx-auto mt-[32px]">
            <p :for={err <- upload_errors(@uploads.file_content)} class="alert alert-danger">
              {err}
            </p>
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
     |> assign(:grade_options, Ingestion.grades())
     |> assign(:subject_options, Ingestion.subjects())
     |> assign(:ingestion, %Ingestion{})
     |> allow_upload(:file_content, accept: ~w(.txt), max_entries: 1, max_file_size: 15_000_000)
     |> assign(:form, to_form(Ingestion.changeset(%Ingestion{}, %{})))}
  end

  @impl true
  def handle_event("validate", %{"ingestion" => ingestion_params}, socket) do
    changeset = Ingestion.changeset(%Ingestion{}, ingestion_params)
    {:noreply, socket |> assign(form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("ingest", %{"ingestion" => ingestion_params}, socket) do
    file_content = get_file_content(socket)
    ingestion_params = Map.put(ingestion_params, "file_content", file_content)

    case TeacherCoop.Curriculum.bulk_add_objectives_from_file(2024, ingestion_params) do
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

  defp get_file_content(socket) do
    content =
      consume_uploaded_entries(socket, :file_content, fn %{path: path}, _ ->
        content = File.read!(path)
        {:ok, content}
      end)

    content |> Enum.at(0)
  end
end

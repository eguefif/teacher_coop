defmodule TeacherCoop.DocumentLive.Components do
  use Gettext, backend: TeacherCoopWeb.Gettext
  use TeacherCoopWeb, :live_view

  attr :document, :map, default: nil

  def download_all_button(assigns) do
    ~H"""
    <div :if={@document != nil}>
      <.link
        class="btn btn-primary"
        href={~p"/documents/download/#{@document}"}
      >{gettext("Download all")}</.link>
    </div>
    """
  end
end

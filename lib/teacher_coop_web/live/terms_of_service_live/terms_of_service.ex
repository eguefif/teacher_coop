defmodule TeacherCoopWeb.TermsOfServiceLive do
  use TeacherCoopWeb, :live_view

  embed_templates "terms_of_service_*"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <article id="terms-of-service" class="mx-auto max-w-3xl space-y-6 leading-relaxed">
        <%= case Gettext.get_locale(TeacherCoopWeb.Gettext) do %>
          <% "fr" -> %>
            <.terms_of_service_fr />
          <% _ -> %>
            <.terms_of_service_en />
        <% end %>
      </article>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

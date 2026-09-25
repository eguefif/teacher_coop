defmodule TeacherCoopWeb.LegalMentionsLive do
  use TeacherCoopWeb, :live_view

  embed_templates "legal_mentions_*"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <article id="legal-mentions">
        <%= case Gettext.get_locale(TeacherCoopWeb.Gettext) do %>
          <% "fr" -> %>
            <.legal_mentions_fr />
          <% _ -> %>
            <.legal_mentions_en />
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

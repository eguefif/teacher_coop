defmodule TeacherCoopWeb.PrivacyPolicyLive do
  use TeacherCoopWeb, :live_view

  embed_templates "privacy_policy_*"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <article id="privacy-policy" class="mx-auto max-w-3xl space-y-6 leading-relaxed">
        <%= case Gettext.get_locale(TeacherCoopWeb.Gettext) do %>
          <% "fr" -> %>
            <.privacy_policy_fr />
          <% _ -> %>
            <.privacy_policy_en />
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

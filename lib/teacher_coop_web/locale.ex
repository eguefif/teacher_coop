defmodule TeacherCoopWeb.Locale do
  @moduledoc """
  Sets the Gettext locale from the `"locale"` session key.

  Used as a plug in the browser pipeline and as an `on_mount` hook in
  every `live_session`, since the locale is stored per process.
  """

  import Plug.Conn

  @locales ~w(en fr)

  def locales, do: @locales

  def supported?(locale), do: locale in @locales

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = conn |> get_session("locale") |> put_locale()
    assign(conn, :locale, locale)
  end

  def on_mount(:set_locale, _params, session, socket) do
    locale = put_locale(session["locale"])
    {:cont, Phoenix.Component.assign(socket, :locale, locale)}
  end

  defp put_locale(locale) when locale in @locales do
    Gettext.put_locale(locale)
    locale
  end

  defp put_locale(_locale), do: Gettext.get_locale()
end

defmodule TeacherCoopWeb.LocaleController do
  use TeacherCoopWeb, :controller

  alias TeacherCoopWeb.Locale

  def update(conn, %{"locale" => locale}) do
    conn =
      if Locale.supported?(locale),
        do: put_session(conn, "locale", locale),
        else: conn

    redirect(conn, to: return_path(conn))
  end

  # Only keep the path of the referer so we never redirect to another host.
  defp return_path(conn) do
    with [referer | _] <- get_req_header(conn, "referer"),
         %URI{path: "/" <> rest = path, query: query} <- URI.parse(referer),
         false <- String.starts_with?(rest, ["/", "\\"]) do
      if query, do: path <> "?" <> query, else: path
    else
      _ -> ~p"/"
    end
  end
end

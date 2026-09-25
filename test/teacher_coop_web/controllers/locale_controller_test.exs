defmodule TeacherCoopWeb.LocaleControllerTest do
  use TeacherCoopWeb.ConnCase, async: true

  describe "GET /locale/:locale" do
    test "stores a supported locale and redirects back to the referer path", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "http://www.example.com/privacy-policy?x=1")
        |> get(~p"/locale/en")

      assert get_session(conn, "locale") == "en"
      assert redirected_to(conn) == "/privacy-policy?x=1"
    end

    test "ignores an unsupported locale", %{conn: conn} do
      conn = get(conn, ~p"/locale/de")

      refute get_session(conn, "locale")
      assert redirected_to(conn) == ~p"/"
    end

    test "never redirects to another host", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "http://www.example.com//evil.com/path")
        |> get(~p"/locale/fr")

      assert redirected_to(conn) == ~p"/"
    end

    test "the chosen locale is used on the next page", %{conn: conn} do
      conn = conn |> get(~p"/locale/fr") |> recycle() |> get(~p"/legal-mentions")

      document = conn |> html_response(200) |> LazyHTML.from_document()

      assert LazyHTML.attribute(LazyHTML.query(document, "html"), "lang") == ["fr"]
      assert LazyHTML.text(LazyHTML.query(document, "#legal-mentions h1")) == "Mentions légales"
    end
  end
end

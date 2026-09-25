defmodule TeacherCoopWeb.LegalMentionsLiveTest do
  use TeacherCoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Legal mentions page" do
    test "renders the English legal notice by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/legal-mentions")

      assert has_element?(view, "#legal-mentions #legal-mentions-en")
      refute has_element?(view, "#legal-mentions-fr")
    end

    test "renders the French legal mentions when the locale is fr", %{conn: conn} do
      conn = init_test_session(conn, %{"locale" => "fr"})
      {:ok, view, _html} = live(conn, ~p"/legal-mentions")

      assert has_element?(view, "#legal-mentions #legal-mentions-fr")
      refute has_element?(view, "#legal-mentions-en")
    end

    test "falls back to English for an unsupported locale", %{conn: conn} do
      conn = init_test_session(conn, %{"locale" => "de"})
      {:ok, view, _html} = live(conn, ~p"/legal-mentions")

      assert has_element?(view, "#legal-mentions-en")
    end

    test "is accessible to logged in users", %{conn: conn} do
      %{conn: conn} = register_and_log_in_user(%{conn: conn})
      {:ok, view, _html} = live(conn, ~p"/legal-mentions")

      assert has_element?(view, "#legal-mentions-en")
    end

    test "links to the privacy policy in both languages", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/legal-mentions")
      assert has_element?(view, ~s(#legal-mentions-en a[href="/privacy-policy"]))

      conn = init_test_session(conn, %{"locale" => "fr"})
      {:ok, view, _html} = live(conn, ~p"/legal-mentions")
      assert has_element?(view, ~s(#legal-mentions-fr a[href="/privacy-policy"]))
    end

    test "links to the AGPL-3.0 licence and the source code", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/legal-mentions")

      assert has_element?(
               view,
               ~s(#legal-mentions a[href^="https://www.gnu.org/licenses/agpl-3.0"])
             )

      assert has_element?(
               view,
               ~s(#legal-mentions a[href="https://github.com/eguefif/teacher_coop"])
             )
    end
  end
end

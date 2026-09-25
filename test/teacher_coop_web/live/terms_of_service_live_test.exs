defmodule TeacherCoopWeb.TermsOfServiceLiveTest do
  use TeacherCoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Terms of service page" do
    test "renders the English terms by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/terms-of-service")

      assert has_element?(view, "#terms-of-service #terms-of-service-en")
      refute has_element?(view, "#terms-of-service-fr")
    end

    test "renders the French terms when the locale is fr", %{conn: conn} do
      conn = init_test_session(conn, %{"locale" => "fr"})
      {:ok, view, _html} = live(conn, ~p"/terms-of-service")

      assert has_element?(view, "#terms-of-service #terms-of-service-fr")
      refute has_element?(view, "#terms-of-service-en")
    end

    test "falls back to English for an unsupported locale", %{conn: conn} do
      conn = init_test_session(conn, %{"locale" => "de"})
      {:ok, view, _html} = live(conn, ~p"/terms-of-service")

      assert has_element?(view, "#terms-of-service-en")
    end

    test "is accessible to logged in users", %{conn: conn} do
      %{conn: conn} = register_and_log_in_user(%{conn: conn})
      {:ok, view, _html} = live(conn, ~p"/terms-of-service")

      assert has_element?(view, "#terms-of-service-en")
    end
  end
end

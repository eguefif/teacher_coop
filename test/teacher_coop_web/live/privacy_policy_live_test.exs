defmodule TeacherCoopWeb.PrivacyPolicyLiveTest do
  use TeacherCoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Privacy policy page" do
    test "renders the English policy by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/privacy-policy")

      assert has_element?(view, "#privacy-policy #privacy-policy-en")
      refute has_element?(view, "#privacy-policy-fr")
    end

    test "renders the French policy when the locale is fr", %{conn: conn} do
      conn = init_test_session(conn, %{"locale" => "fr"})
      {:ok, view, _html} = live(conn, ~p"/privacy-policy")

      assert has_element?(view, "#privacy-policy #privacy-policy-fr")
      refute has_element?(view, "#privacy-policy-en")
    end

    test "falls back to English for an unsupported locale", %{conn: conn} do
      conn = init_test_session(conn, %{"locale" => "de"})
      {:ok, view, _html} = live(conn, ~p"/privacy-policy")

      assert has_element?(view, "#privacy-policy-en")
    end

    test "is accessible to logged in users", %{conn: conn} do
      %{conn: conn} = register_and_log_in_user(%{conn: conn})
      {:ok, view, _html} = live(conn, ~p"/privacy-policy")

      assert has_element?(view, "#privacy-policy-en")
    end
  end
end

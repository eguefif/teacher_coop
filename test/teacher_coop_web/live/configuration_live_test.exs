defmodule TeacherCoopWeb.ConfigurationLiveTest do
  use TeacherCoopWeb.ConnCase

  import Phoenix.LiveViewTest
  import TeacherCoop.ConfigurationFixtures

  @create_attrs %{name: "some configuration", engine: "meilisearch"}
  @update_attrs %{name: "some updated configuration", engine: "meilisearch"}
  @invalid_attrs %{name: nil, engine: nil}

  setup :register_and_log_in_admin_user

  defp create_configuration(%{scope: scope}) do
    configuration = configuration_fixture(scope)

    %{configuration: configuration}
  end

  describe "Index" do
    setup [:create_configuration]

    test "lists all configurations", %{conn: conn, configuration: configuration} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/configurations")

      assert html =~ "Index Configurations"
      assert html =~ configuration.name
    end

    test "saves new configuration", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/configurations")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Index")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/configurations/new")

      assert render(form_live) =~ "Configuration"

      assert form_live
             |> form("#configuration-form", engine_configuration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#configuration-form", engine_configuration: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/configurations")

      html = render(index_live)
      assert html =~ "Configuration created successfully"
      assert html =~ "some configuration"
    end

    test "updates configuration in listing", %{conn: conn, configuration: configuration} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/configurations")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#configurations-#{configuration.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/configurations/#{configuration}/edit")

      assert render(form_live) =~ "Configuration"

      assert form_live
             |> form("#configuration-form", engine_configuration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#configuration-form", engine_configuration: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/configurations")

      html = render(index_live)
      assert html =~ "Configuration updated successfully"
      assert html =~ "some updated configuration"
    end

    test "deletes configuration in listing", %{conn: conn, configuration: configuration} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/configurations")

      assert index_live
             |> element("#configurations-#{configuration.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#configurations-#{configuration.id}")
    end
  end

  describe "Show" do
    setup [:create_configuration]

    test "displays configuration", %{conn: conn, configuration: configuration} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/configurations/#{configuration}")

      assert html =~ "Configuration"
      assert html =~ configuration.name
    end

    test "updates configuration from show and returns to index", %{
      conn: conn,
      configuration: configuration
    } do
      {:ok, show_live, _html} = live(conn, ~p"/admin/configurations/#{configuration}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit Index")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/configurations/#{configuration}/edit")

      assert render(form_live) =~ "Configuration"

      assert form_live
             |> form("#configuration-form", engine_configuration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#configuration-form", engine_configuration: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/configurations")

      html = render(index_live)
      assert html =~ "Configuration updated successfully"
      assert html =~ "some updated configuration"
    end
  end
end

defmodule TeacherCoopWeb.IndexLiveTest do
  use TeacherCoopWeb.ConnCase

  import Phoenix.LiveViewTest
  import TeacherCoop.ConfigurationFixtures

  @create_attrs %{uid: "some index"}
  @update_attrs %{uid: "some updated index"}
  @invalid_attrs %{uid: nil}

  setup :register_and_log_in_admin_user

  defp create_index(%{scope: scope}) do
    index = index_fixture(scope)

    %{index: index}
  end

  describe "Index" do
    setup [:create_index]

    test "list all index", %{conn: conn, index: index} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/indexes")

      assert html =~ "Listing Index"
      assert html =~ index.uid
    end

    test "saves new document", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/indexes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Index")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/indexes/new")

      assert render(form_live) =~ "New Index"

      assert form_live
             |> form("#index-form", index: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#index-form", index: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/indexes")

      html = render(index_live)
      assert html =~ "Index created successfully"
      assert html =~ "some index"
    end

    test "updates document", %{conn: conn, index: index} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/indexes")

      assert {:ok, form_live, _} =
               index_live
               |> element("#indexes-#{index.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/indexes/#{index}/edit")

      assert render(form_live) =~ "Edit Index"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#index-form", index: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/indexes")

      html = render(index_live)
      assert html =~ "Index updated successfully"
      assert html =~ "some updated index"
    end

    test "deletes indexes in listing", %{conn: conn, index: index} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/indexes")

      assert index_live |> element("#delete-#{index.id}") |> render_click()
      refute has_element?(index_live, "a[phx-value-id='#{index.id}']")
    end
  end

  describe "Show" do
    setup [:create_index]

    test "displays index", %{conn: conn, index: index} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/indexes/#{index}")

      assert html =~ "Index"
      assert html =~ index.uid
    end

    test "udpates index and returns to show", %{conn: conn, index: index} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/indexes/#{index}")

      assert {:ok, form_live, _html} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/indexes/#{index}/edit?return_to=show")

      assert render(form_live) =~ "Edit Index"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#index-form", index: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/indexes/#{index}")

      html = render(show_live)
      assert html =~ "Index updated successfully"
      assert html =~ "some updated index"
    end
  end
end

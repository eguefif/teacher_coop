defmodule TeacherCoopWeb.DocumentLiveTest do
  use TeacherCoopWeb.ConnCase

  import Phoenix.LiveViewTest
  import TeacherCoop.LibraryFixtures
  import TeacherCoop.AccountsFixtures

  @create_attrs %{description: "some description", title: "some title"}
  @update_attrs %{description: "some updated description", title: "some updated title"}
  @invalid_attrs %{description: nil, title: nil}

  setup :register_and_log_in_user

  defp create_document(%{scope: scope}) do
    document = document_fixture(scope)

    %{document: document}
  end

  defp create_document_no_scope(%{}) do
    user = add_random_user()
    scope = TeacherCoop.Accounts.Scope.for_user(user)
    document = document_fixture(scope)

    %{document: document}
  end

  describe "Index" do
    setup [:create_document]

    test "lists all documents", %{conn: conn, document: document} do
      {:ok, _index_live, html} = live(conn, ~p"/documents")

      assert html =~ "Listing Documents"
      assert html =~ document.title
    end

    test "saves new document", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/documents")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Document")
               |> render_click()
               |> follow_redirect(conn, ~p"/documents/new")

      assert render(form_live) =~ "New Document"

      assert form_live
             |> form("#document-form", document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} = fill_new_form(form_live, conn)

      html = render(index_live)
      assert html =~ "Document created successfully"
      assert html =~ "some title"
    end

    defp fill_new_form(form_live, conn) do
      form_live
      |> form("#document-form", document: @create_attrs)
      |> render_submit()
      |> follow_redirect(conn, ~p"/documents")
    end

    test "updates document in listing", %{conn: conn, document: document} do
      {:ok, index_live, _html} = live(conn, ~p"/documents")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#documents-#{document.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/documents/#{document}/edit")

      assert render(form_live) =~ "Edit Document"

      assert form_live
             |> form("#document-form", document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#document-form", document: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/documents")

      html = render(index_live)
      assert html =~ "Document updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes document in listing", %{conn: conn, document: document} do
      {:ok, index_live, _html} = live(conn, ~p"/documents")

      assert index_live |> element("a[phx-value-id='#{document.id}']") |> render_click()
      refute has_element?(index_live, "#documents-#{document.id}")
    end
  end

  describe "Show" do
    setup [:create_document]

    test "displays document", %{conn: conn, document: document} do
      {:ok, _show_live, html} = live(conn, ~p"/documents/#{document}")

      assert html =~ "Show Document"
      assert html =~ document.title
    end

    test "displays document that returns to search", %{conn: conn, document: document} do
      {:ok, show_live, html} = live(conn, ~p"/documents/#{document}?return_to=search")

      assert html =~ "Show Document"
      assert html =~ document.title

      assert {:ok, _, _} =
               show_live
               |> element("#return-to")
               |> render_click()
               |> follow_redirect(conn, ~p"/search")
    end

    test "updates document and returns to show", %{conn: conn, document: document} do
      {:ok, show_live, _html} = live(conn, ~p"/documents/#{document}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/documents/#{document}/edit?return_to=show")

      assert render(form_live) =~ "Edit Document"

      assert form_live
             |> form("#document-form", document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#document-form", document: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/documents/#{document}")

      html = render(show_live)
      assert html =~ "Document updated successfully"
      assert html =~ "some updated title"
    end
  end

  describe "Show when user is not the owner" do
    setup [:create_document_no_scope]

    test "displays document", %{conn: conn, document: document} do
      {:ok, _show_live, html} = live(conn, ~p"/documents/#{document}")

      assert html =~ "Show Document"
      assert html =~ document.title
      assert html =~ document.user.fullname
    end
  end
end

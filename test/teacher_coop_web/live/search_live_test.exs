defmodule TeacherCoopWeb.SearchLiveTest do
  use TeacherCoopWeb.ConnCase

  import Phoenix.LiveViewTest
  import TeacherCoop.LibraryFixtures

  alias TeacherCoop.Discovery
  alias TeacherCoop.SearchRepo.SearchDocuments

  @search_terms %{"search_terms" => "exercice fraction"}
  @empty_search_terms %{"search_terms" => ""}
  @invalid_search_terms %{"search_terms" => "asfjdsa137123021fkljdsafhdsafsadfasdfsdafds;"}

  setup :register_and_log_in_user

  defp create_documents(%{scope: scope}) do
    relative_path = "files/test-file-#{System.unique_integer([:positive])}"

    documents =
      [
        %{
          title: "Sequence sur les fractions",
          description: "Ensemble d'exercices pratiques sur les fractions pour ce2",
          files: [%{filename: "lesson.pdf", filepath: relative_path, format: "pdf"}]
        },
        %{
          title: "Fractions en ligne",
          description:
            "Leçon + séance exploratoire pour enseigner le placement des fractions sur une bande graduée"
        },
        %{
          title: "Opérations sur les fractions ",
          description: "Révision des 4 opérations avec les fractions"
        }
      ]
      |> Enum.map(&document_fixture(scope, &1))

    Oban.drain_queue(queue: :document_ingestion)

    file_path = Path.join(Application.app_dir(:teacher_coop, "priv/static"), relative_path)
    File.mkdir_p!(Path.dirname(file_path))
    File.write!(file_path, "test file content")

    on_exit(fn ->
      Enum.each(documents, &SearchDocuments.delete_document(&1.id))
      File.rm(file_path)
    end)

    %{documents: documents}
  end

  describe "Search" do
    setup [:create_documents]

    test "Make search", %{conn: conn, documents: documents} do
      {:ok, search_live, html} = live(conn, ~p"/")

      assert html =~ "search"

      assert result_html =
               search_live
               |> form("#search-form", @search_terms)
               |> render_submit()

      assert result_html =~ Enum.at(documents, 0) |> Map.get(:title)
    end

    test "Make two searches", %{conn: conn, documents: documents} do
      {:ok, search_live, html} = live(conn, ~p"/")

      assert html =~ "search"

      document_title = Enum.at(documents, 1) |> Map.get(:title)

      assert search_live
             |> form("#search-form", @search_terms)
             |> render_submit()

      assert result_html =
               search_live
               |> form("#search-form", %{search_terms: document_title})
               |> render_submit()

      assert result_html =~ document_title
    end

    test "Make search: no result", %{conn: conn} do
      {:ok, search_live, html} = live(conn, ~p"/")

      assert html =~ "search"

      assert result_html =
               search_live
               |> form("#search-form", @invalid_search_terms)
               |> render_submit()

      assert result_html =~ "Oops"
    end

    test "search_terms are empty", %{conn: conn} do
      {:ok, search_live, html} = live(conn, ~p"/")

      assert html =~ "search"

      assert search_live
             |> form("#search-form", @empty_search_terms)
             |> render_submit()
    end

    test "click on preview", %{conn: conn, documents: documents} do
      {:ok, search_live, html} = live(conn, ~p"/")

      assert html =~ "search"

      document_title = Enum.at(documents, 0) |> Map.get(:title)
      file_id = Enum.at(documents, 0) |> Map.get(:files) |> Enum.at(0) |> Map.get(:id)

      assert search_live
             |> form("#search-form", %{"search_terms" => document_title})
             |> render_submit() =~ document_title

      assert search_live
             |> element("#preview-button-#{file_id}")
             |> render_click()

      assert search_live |> element("object") |> render() =~ "pdf"
    end

    test "click on download", %{conn: conn, documents: documents} do
      {:ok, search_live, html} = live(conn, ~p"/")

      assert html =~ "search"

      document = Enum.at(documents, 0)
      document_title = document |> Map.get(:title)
      file = document |> Map.get(:files) |> Enum.at(0)

      assert search_live
             |> form("#search-form", %{"search_terms" => document_title})
             |> render_submit() =~ document_title

      assert {:ok, result} =
               search_live
               |> element("#download-button-#{file.id}")
               |> render_click()
               |> follow_redirect(conn, ~p"/files/#{file}")

      search = Discovery.get_search_by_search_terms!(document_title)
      assert search.state == "success"

      assert result.resp_body
    end

    test "click on download all", %{conn: conn, documents: documents} do
      {:ok, search_live, html} = live(conn, ~p"/")

      assert html =~ "search"

      document = Enum.at(documents, 0)
      document_title = document |> Map.get(:title)
      document_id = document |> Map.get(:id)

      assert search_live
             |> form("#search-form", %{"search_terms" => document_title})
             |> render_submit() =~ document_title

      assert {:ok, result} =
               search_live
               |> element("#download-all-button-#{document_id}")
               |> render_click()
               |> follow_redirect(conn, ~p"/documents/download/#{document}")

      search = Discovery.get_search_by_search_terms!(document_title)
      assert search.state == "success"

      assert result.resp_body
    end
  end
end

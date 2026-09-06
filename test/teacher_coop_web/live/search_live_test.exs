defmodule TeacherCoopWeb.SearchLiveTest do
  use TeacherCoopWeb.ConnCase

  import Phoenix.LiveViewTest
  import TeacherCoop.LibraryFixtures

  alias TeacherCoop.SearchRepo.SearchDocuments

  @search_terms %{"search_terms" => "exercice fraction"}
  @invalid_search_terms %{"search_terms" => "asfjdsa137123021fkljdsafhdsafsadfasdfsdafds;"}

  setup :register_and_log_in_user

  defp create_documents(%{scope: scope}) do
    documents =
      [
        %{
          title: "Sequence sur les fractions",
          description: "Ensemble d'exercices pratiques sur les fractions pour ce2"
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

    on_exit(fn ->
      Enum.each(documents, &SearchDocuments.delete_document(&1.id))
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

    test "Make search: no result", %{conn: conn} do
      {:ok, search_live, html} = live(conn, ~p"/")

      assert html =~ "search"

      assert result_html =
               search_live
               |> form("#search-form", @invalid_search_terms)
               |> render_submit()

      assert result_html =~ "Oops"
    end
  end
end

defmodule TeacherCoopWeb.CurriculumLiveTest do
  use TeacherCoopWeb.ConnCase

  import Phoenix.LiveViewTest
  import TeacherCoop.CurriculumFixtures

  defp create_objectives(_context) do
    objectives = [
      objective_fixture(%{year: 2024, grade: "6e", subject: "français", strand: "lire"}),
      objective_fixture(%{year: 2024, grade: "6e", subject: "français", strand: "écrire"}),
      objective_fixture(%{year: 2024, grade: "5e", subject: "mathématiques", strand: "compter"}),
      objective_fixture(%{year: 2024, grade: "5e", subject: "histoire", strand: "moyen âge"}),
      # Different year: must not be counted
      objective_fixture(%{year: 2023, grade: "cm2", subject: "sciences", strand: "vivant"})
    ]

    %{objectives: objectives}
  end

  describe "Index as admin" do
    setup [:register_and_log_in_admin_user, :create_objectives]

    test "displays subject counts grouped by grade", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/curriculum")

      render_async(view)

      assert has_element?(view, "#curriculum-stats")
      assert has_element?(view, "#grade-6e")
      assert has_element?(view, "#grade-5e")

      assert view |> element("#grade-6e li", "Français") |> render() =~ "2"
      assert view |> element("#grade-5e li", "Mathématiques") |> render() =~ "1"
      assert view |> element("#grade-5e li", "Histoire") |> render() =~ "1"
    end

    test "only displays objectives from the current year", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/curriculum")

      render_async(view)

      refute has_element?(view, "#grade-cm2")
    end
  end

  describe "Index as non-admin" do
    setup :register_and_log_in_user

    test "redirects to home", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/admin/curriculum")
    end
  end
end

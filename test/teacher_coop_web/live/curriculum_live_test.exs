defmodule TeacherCoopWeb.CurriculumLiveTest do
  use TeacherCoopWeb.ConnCase
  use Oban.Testing, repo: TeacherCoop.Repo

  import Phoenix.LiveViewTest
  import TeacherCoop.CurriculumFixtures

  @valid_attrs %{year: 2022}

  defp create_objectives(_context) do
    objectives = [
      objective_fixture(%{
        year: 2024,
        grade: "6",
        subject: "français",
        strand: "lire",
        goal: "savoir live"
      }),
      objective_fixture(%{
        year: 2024,
        grade: "6",
        subject: "français",
        strand: "écrire",
        goal: "savoir écrire"
      }),
      objective_fixture(%{
        year: 2024,
        grade: "5",
        subject: "mathématiques",
        strand: "compter",
        goal: "savoir compter"
      }),
      objective_fixture(%{
        year: 2024,
        grade: "5",
        subject: "histoire",
        strand: "moyen âge",
        goal: "Connaître le moyen-âge"
      }),
      # Different year: must not be counted
      objective_fixture(%{
        year: 2023,
        grade: "cm2",
        subject: "sciences",
        strand: "vivant",
        goal: "le vivant"
      })
    ]

    %{objectives: objectives}
  end

  describe "Index as admin" do
    setup [:register_and_log_in_admin_user, :create_objectives]

    test "displays subject counts grouped by grade", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/curriculum")

      render_async(view)

      assert has_element?(view, "#curriculum-stats")
      assert has_element?(view, "#grade-6")
      assert has_element?(view, "#grade-5")

      assert view |> element("#grade-6 li", "Français") |> render() =~ "2"
      assert view |> element("#grade-5 li", "Mathématiques") |> render() =~ "1"
      assert view |> element("#grade-5 li", "Histoire") |> render() =~ "1"
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

  describe "form" do
    setup [:register_and_log_in_admin_user, :create_objectives]

    def file_input(view) do
      file_input(view, "#curriculum-form", :file_content, [
        %{
          name: "français.txt",
          content: "Some curriculum content",
          type: "text/plain"
        }
      ])
    end

    test "Fill form and submit", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/curriculum")

      assert {:ok, view, _} =
               index_live
               |> element("a", "Ingest")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/curriculum/new")

      assert has_element?(view, "#curriculum-form")
      assert has_element?(view, "#year-input")

      render_upload(file_input(view), "français.txt")

      assert view
             |> form("#curriculum-form", curriculum_ingestion: @valid_attrs)
             |> render_submit()
             |> follow_redirect(conn, ~p"/admin/curriculum")

      oban_job_attrs =
        %{
          "filecontent" => "Some curriculum content",
          "year" => 2022,
          "subject" => "français"
        }

      assert_enqueued(
        worker: TeacherCoop.Curriculum.FileIngestionWorker,
        args: oban_job_attrs
      )
    end
  end
end

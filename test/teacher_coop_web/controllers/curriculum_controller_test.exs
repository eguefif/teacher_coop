defmodule TeacherCoopWeb.CurriculumControllerTest do
  use TeacherCoopWeb.ConnCase, async: true

  import TeacherCoop.CurriculumFixtures

  describe "GET /api/curriculum" do
    test "lists the objectives, including newly created ones", %{conn: conn} do
      objective = objective_fixture()

      conn = get(conn, ~p"/api/curriculum")

      response = json_response(conn, 200)

      assert %{
               "year" => objective.year,
               "subject" => objective.subject,
               "grade" => objective.grade,
               "strand" => objective.strand,
               "goal" => objective.goal
             } in response
    end
  end
end

defmodule TeacherCoopWeb.FooterTest do
  use TeacherCoopWeb.ConnCase, async: true

  describe "footer" do
    test "shows the copyright, source code and licence links", %{conn: conn} do
      document =
        conn |> get(~p"/legal-mentions") |> html_response(200) |> LazyHTML.from_document()

      refute Enum.empty?(LazyHTML.query(document, "footer #footer-copyright"))

      assert LazyHTML.attribute(LazyHTML.query(document, "#footer-source-code"), "href") ==
               ["https://github.com/eguefif/teacher_coop"]

      assert LazyHTML.attribute(LazyHTML.query(document, "#footer-licence"), "href") ==
               ["https://www.gnu.org/licenses/agpl-3.0.html"]
    end
  end
end

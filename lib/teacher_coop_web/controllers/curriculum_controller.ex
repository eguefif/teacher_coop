defmodule TeacherCoopWeb.CurriculumController do
  use TeacherCoopWeb, :controller
  alias TeacherCoop.Curriculum

  def index(conn, _params) do
    curriculum = Curriculum.list_objectives!()
    render(conn, :index, curriculum: curriculum)
  end
end

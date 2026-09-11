defmodule TeacherCoopWeb.YearController do
  use TeacherCoopWeb, :controller

  def index(conn, _params) do
    year = %{
      a: %{
        periode1: %{start: "2026-09-01", end: "2026-10-16"},
        periode2: %{start: "2026-11-02", end: "2026-12-18"},
        periode3: %{start: "2027-01-04", end: "2027-02-12"},
        periode4: %{start: "2027-03-01", end: "2027-04-09"},
        periode5: %{start: "2027-04-26", end: "2027-07-03"}
      },
      b: %{
        periode1: %{start: "2026-09-01", end: "2026-10-16"},
        periode2: %{start: "2026-11-02", end: "2026-12-18"},
        periode3: %{start: "2027-01-04", end: "2027-02-19"},
        periode4: %{start: "2027-03-08", end: "2027-04-16"},
        periode5: %{start: "2027-05-03", end: "2027-07-03"}
      },
      c: %{
        periode1: %{start: "2026-09-01", end: "2026-10-16"},
        periode2: %{start: "2026-11-02", end: "2026-12-18"},
        periode3: %{start: "2027-01-04", end: "2027-02-06"},
        periode4: %{start: "2027-02-22", end: "2027-04-02"},
        periode5: %{start: "2027-04-19", end: "2027-07-03"}
      }
    }

    render(conn, :index, year: year)
  end
end

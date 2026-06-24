defmodule TeacherCoop.Repo do
  use Ecto.Repo,
    otp_app: :teacher_coop,
    adapter: Ecto.Adapters.Postgres
end

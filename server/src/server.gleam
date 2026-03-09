import app_type.{App}
import gleam/erlang/process
import server/cron_jobs
import server/db
import server/webserver

import gleam/otp/static_supervisor as supervisor

pub fn main() -> Nil {
  let #(db, db_pool) = db.init_db()
  let #(cronjobs, cronjobs_spec) = cron_jobs.init_cron(db)
  let webserver = webserver.init_webserver(App(db:, cronjobs:))

  let assert Ok(_) =
    supervisor.new(supervisor.OneForOne)
    |> supervisor.add(db_pool)
    |> supervisor.add(cronjobs_spec)
    |> supervisor.add(webserver)
    |> supervisor.start()

  process.sleep_forever()
}

import gleam/erlang/process
import server/cron_job
import server/db
import server/webserver

import gleam/otp/static_supervisor as supervisor

pub fn main() -> Nil {
  let #(db, db_pool) = db.init_db()
  let cron = cron_job.init_cron(db)
  let webserver = webserver.init_webserver(db)

  let assert Ok(_) =
    supervisor.new(supervisor.OneForOne)
    |> supervisor.add(db_pool)
    |> supervisor.add(cron)
    |> supervisor.add(webserver)
    |> supervisor.start()

  process.sleep_forever()
}

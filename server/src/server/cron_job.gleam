import clockwork
import clockwork_schedule
import gleam/erlang/process
import gleam/otp/static_supervisor as supervisor
import server/db
import server/sql

pub fn init_cron() {
  let cleanup_sessions = init_cleanup_session()
  let assert Ok(_sup) =
    supervisor.new(supervisor.OneForOne)
    |> supervisor.add(cleanup_sessions)
    |> supervisor.start()
}

fn init_cleanup_session() {
  let assert Ok(cron) = clockwork.from_string("* 0 * * *")
  let scheduler =
    clockwork_schedule.new("Cleanup Sessions", cron, cleanup_sessions)
    |> clockwork_schedule.with_logging()
  let name = process.new_name("Cleanup Sessions")
  clockwork_schedule.supervised(scheduler, name)
}

fn cleanup_sessions() {
  let db = db.init_db()
  let _ = sql.delete_passed_date_session(db)
  Nil
}

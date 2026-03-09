import clockwork
import clockwork_schedule
import gleam/erlang/process
import gleam/otp/static_supervisor as supervisor
import gleam/otp/supervision
import pog
import server/auth/sql

pub fn init_cron(
  db: pog.Connection,
) -> supervision.ChildSpecification(supervisor.Supervisor) {
  let cleanup_sessions = init_cleanup_session(db)
  let child =
    supervisor.new(supervisor.OneForOne)
    |> supervisor.add(cleanup_sessions)
    |> supervisor.supervised()

  child
}

fn init_cleanup_session(db: pog.Connection) {
  let assert Ok(cron) = clockwork.from_string("* 0 * * *")
  let scheduler =
    clockwork_schedule.new("Cleanup Sessions", cron, fn() {
      cleanup_sessions(db)
    })
    |> clockwork_schedule.with_logging()
  let name = process.new_name("Cleanup Sessions")
  clockwork_schedule.supervised(scheduler, name)
}

fn cleanup_sessions(db: pog.Connection) -> Nil {
  let _ = sql.delete_passed_date_session(db)
  Nil
}

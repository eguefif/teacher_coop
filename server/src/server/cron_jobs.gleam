import clockwork
import clockwork_schedule
import gleam/dict
import gleam/erlang/process
import gleam/otp/static_supervisor as supervisor
import gleam/otp/supervision
import pog
import server/auth/sql

pub type CronJob {
  CronJob(process_name: process.Name(clockwork_schedule.Message), started: Bool)
}

pub fn stop_cron(process: process.Name(clockwork_schedule.Message)) {
  clockwork_schedule.stop(process)
}

// TODO: This won'twork. The stop_cron stop the actor
// We need to reinitialize the cleanup and put it back in the supervision tree
pub fn start_cron(process: process.Name(clockwork_schedule.Message)) {
  process.named_subject(process)
  |> process.send(clockwork_schedule.Run)
}

pub fn init_cron(
  db: pog.Connection,
) -> #(
  dict.Dict(String, CronJob),
  supervision.ChildSpecification(supervisor.Supervisor),
) {
  let #(clean_session_name, cleanup_sessions) = init_cleanup_session(db)
  let child =
    supervisor.new(supervisor.OneForOne)
    |> supervisor.add(cleanup_sessions)
    |> supervisor.supervised()

  let cron_jobs =
    dict.from_list([
      #(
        "cleanup_sessions",
        CronJob(process_name: clean_session_name, started: True),
      ),
    ])
  #(cron_jobs, child)
}

fn init_cleanup_session(
  db: pog.Connection,
) -> #(
  process.Name(clockwork_schedule.Message),
  supervision.ChildSpecification(process.Subject(clockwork_schedule.Message)),
) {
  let assert Ok(cron) = clockwork.from_string("* 0 * * *")
  let scheduler =
    clockwork_schedule.new("cleanup_sessions", cron, fn() {
      cleanup_sessions(db)
    })
    |> clockwork_schedule.with_logging()
  let name = process.new_name("cleanup_sessions")
  #(name, clockwork_schedule.supervised(scheduler, name))
}

fn cleanup_sessions(db: pog.Connection) -> Nil {
  let _ = sql.delete_passed_date_session(db)
  Nil
}

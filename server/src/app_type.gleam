import gleam/dict
import pog
import server/cron_jobs

pub type App {
  App(db: pog.Connection, cronjobs: dict.Dict(String, cron_jobs.CronJob))
}

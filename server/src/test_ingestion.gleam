import envoy
import gleam/erlang/process
import pog
import server/school/school_ingestion as si

pub fn main() {
  let db_name = process.new_name("db_pool")
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(config) = pog.url_config(db_name, database_url)
  let assert Ok(_) = config |> pog.pool_size(10) |> pog.start()
  si.ingest_french_school(pog.named_connection(db_name), False)
}

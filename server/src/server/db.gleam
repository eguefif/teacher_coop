import envoy
import gleam/erlang/process
import gleam/list
import gleam/otp/supervision
import gleam/string
import pog

pub fn init_db() -> #(
  pog.Connection,
  supervision.ChildSpecification(pog.Connection),
) {
  let db_pool_name = process.new_name("db_pool")
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(pog_config) = pog.url_config(db_pool_name, database_url)
  let child =
    pog_config
    |> pog.pool_size(10)
    |> pog.supervised

  #(pog.named_connection(db_pool_name), child)
}

pub fn init_db_start() -> pog.Connection {
  let db_pool_name = process.new_name("db_pool")
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(pog_config) = pog.url_config(db_pool_name, database_url)
  let _ =
    pog_config
    |> pog.pool_size(10)
    |> pog.start

  pog.named_connection(db_pool_name)
}

/// Returns the string contains in "" in a constraint error message from pog 
///
/// Example:
///   message:  duplicate key value violates unique constraint "unique_email"
///   It will return unique_email
///
/// When creating a new constraint, we need to give it an email
pub fn extract_constraint_name(error: String) -> String {
  string.crop(error, "\"")
  |> string.trim_end()
  |> string.drop_end(1)
  |> string.drop_start(1)
}

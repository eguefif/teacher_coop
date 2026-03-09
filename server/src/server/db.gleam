import envoy
import gleam/erlang/process
import gleam/otp/supervision
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

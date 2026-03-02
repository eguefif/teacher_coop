import envoy
import gleam/erlang/process
import gleam/http.{Post}
import gleam/string
import mist
import pog
import server/auth_controller
import server/middleware
import server/user_controller
import wisp.{type Request, type Response}
import wisp/wisp_mist

// TODO: Handle session in Client
pub fn main() -> Nil {
  wisp.configure_logger()
  let db = init_db()
  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    handle_request(db, _)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start

  process.sleep_forever()
}

fn handle_request(db: pog.Connection, req: Request) -> Response {
  use #(req, session) <- middleware.app_middleware(db, req)

  case req.method, wisp.path_segments(req) {
    Post, ["signup"] -> user_controller.handle_request_user(db, req)
    _, ["auth", _] -> auth_controller.handle_request_login(db, req, session)
    _, _ -> wisp.not_found()
  }
}

fn init_db() -> pog.Connection {
  let db_pool_name = process.new_name("db_pool")
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(pog_config) = pog.url_config(db_pool_name, database_url)
  let assert Ok(_) =
    pog_config
    |> pog.pool_size(10)
    |> pog.start

  pog.named_connection(db_pool_name)
}

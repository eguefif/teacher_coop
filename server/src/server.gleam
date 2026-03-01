import envoy
import gleam/erlang/process
import gleam/float
import gleam/http.{Post}
import gleam/time/timestamp
import mist
import pog
import server/session.{type CurrentSession, CurrentSession}
import server/session_controller.{handle_request_login, try_get_session}
import server/user_controller.{handle_request_user}
import wisp.{type Request, type Response}
import wisp/wisp_mist
import youid/uuid

// TODO: Create session on successfull signup

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

fn app_middleware(
  db: pog.Connection,
  req: Request,
  next: fn(#(Request, CurrentSession)) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  let session = try_get_session(db, req)

  let response = next(#(req, session))
  case session {
    CurrentSession(id, expiration, _) ->
      response
      |> wisp.set_cookie(
        req,
        "sessionId",
        uuid.to_string(id),
        wisp.Signed,
        float.round(timestamp.to_unix_seconds(expiration)),
      )
    _ -> response
  }
}

fn handle_request(db: pog.Connection, req: Request) -> Response {
  use #(req, _session) <- app_middleware(db, req)

  // TODO: Refactor, have one route for signup and login
  case req.method, wisp.path_segments(req) {
    Post, ["signup"] -> handle_request_user(db, req)
    Post, ["login"] -> handle_request_login(db, req)
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

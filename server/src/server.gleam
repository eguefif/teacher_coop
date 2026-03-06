import envoy
import gleam/erlang/process
import gleam/http.{Post}
import gleam/int
import mist
import pog
import server/auth/auth_controller
import server/cron_job
import server/db
import server/file/file_controller
import server/middleware
import server/user/user_controller
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()

  let db = db.init_db()
  let _ = cron_job.init_cron()
  let secret_key_base = case envoy.get("SECRET_KEY") {
    Ok(key) -> key
    Error(_) -> "123451234"
  }
  let port = get_port()
  let host = get_host()

  let assert Ok(_) =
    handle_request(db, _)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.bind(host)
    |> mist.port(port)
    |> mist.start

  process.sleep_forever()
}

fn handle_request(db: pog.Connection, req: Request) -> Response {
  use #(req, session) <- middleware.app_middleware(db, req)
  use req <- middleware.verify_auth(req, session)

  wisp.log_info("In handle request path: " <> req.path)
  case req.method, wisp.path_segments(req) {
    Post, ["signup"] -> user_controller.handle_request_user(db, req)
    _, ["auth", _] -> auth_controller.handle_request_login(db, req, session)
    _, ["file", ..] -> file_controller.handle_request_file(db, req, session)
    _, _ -> wisp.not_found()
  }
}

fn get_port() -> Int {
  case envoy.get("PORT") {
    Ok(port) -> {
      case int.parse(port) {
        Ok(port_number) -> port_number
        Error(_) -> 8080
      }
    }
    Error(_) -> 3000
  }
}

fn get_host() -> String {
  case envoy.get("HOST") {
    Ok(host) -> host
    Error(_) -> "localhost"
  }
}

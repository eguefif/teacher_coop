import gleam/erlang/process
import gleam/http.{Post}
import mist
import server/user.{handle_request_user}
import wisp.{type Request, type Response}
import wisp/wisp_mist

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

fn app_middleware(req: Request, next: fn(Request) -> Response) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  next(req)
}

fn handle_request(db: req: Request) -> Response {
  use req <- app_middleware(req)

  case req.method, wisp.path_segments(req) {
    Post, ["signup"] -> handle_request_user(req)
    _, _ -> wisp.not_found()
  }
}

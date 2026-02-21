import gleam/dynamic/decode
import gleam/erlang/process
import gleam/http.{Options, Post}
import gleam/io
import mist
import shared/user.{user_decoder}
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    handle_request
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

fn handle_request(req: Request) -> Response {
  use req <- app_middleware(req)

  case req.method, wisp.path_segments(req) {
    Post, ["signup"] -> create_user(req)
    _, _ -> wisp.not_found()
  }
}

fn create_user(req: Request) -> Response {
  use json <- wisp.require_json(req)

  case decode.run(json, user_decoder()) {
    Ok(user) -> {
      io.print("New user: " <> user.full_name)
      wisp.ok()
    }
    Error(_) -> wisp.unprocessable_content()
  }
}

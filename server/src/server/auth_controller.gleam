import gleam/dynamic/decode
import gleam/http.{Delete, Post}
import gleam/option
import pog
import server/session
import server/user_controller
import shared/user
import wisp.{type Request, type Response}
import youid/uuid

pub fn handle_request_login(db: pog.Connection, req: Request) -> Response {
  case req.method, wisp.path_segments(req) {
    Post, ["login"] -> login_user(db, req)
    Delete, ["logout"] -> session.destroy_session(db, req)
    _, _ -> wisp.not_found()
  }
}

fn login_user(db: pog.Connection, req: Request) -> Response {
  use json <- wisp.require_json(req)
  case decode.run(json, user.user_login_form_decoder()) {
    Ok(user) -> {
      let assert user.UserLoginForm(email, password) = user
      case user_controller.check_password(db, email, password) {
        option.Some(id) -> {
          case session.init_session(db, id) {
            Ok(id) ->
              wisp.ok()
              |> wisp.set_cookie(
                req,
                "sessionId",
                uuid.to_string(id),
                wisp.Signed,
                session.session_ttl,
              )
            Error(_error) -> wisp.internal_server_error()
          }
        }
        option.None -> wisp.response(403)
      }
    }
    Error(_) -> wisp.unprocessable_content()
  }
}

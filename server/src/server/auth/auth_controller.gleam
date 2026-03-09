import gleam/dynamic/decode
import gleam/http.{Delete, Get, Post}
import gleam/json
import gleam/option
import pog
import server/auth/session
import server/user/user_controller
import shared/user
import wisp.{type Request, type Response}
import youid/uuid

pub fn handle_auth(
  db: pog.Connection,
  req: Request,
  session: session.CurrentSession,
) -> Response {
  case req.method, wisp.path_segments(req) {
    Post, [_, "login"] -> login_user(db, req)
    Get, [_, "whoami"] -> whoami(session)
    Delete, [_, "logout"] -> session.destroy_session(db, req)
    _, _ -> wisp.not_found()
  }
}

fn login_user(db: pog.Connection, req: Request) -> Response {
  use json <- wisp.require_json(req)
  case decode.run(json, user.user_login_form_decoder()) {
    Ok(user) -> {
      let assert user.UserLoginForm(email, password) = user
      case user_controller.check_password(db, email, password) {
        option.Some(user) -> {
          let assert user.User(..) = user
          case session.init_session(db, user.id) {
            Ok(id) ->
              wisp.ok()
              |> wisp.json_body(json.to_string(user.user_to_json(user)))
              |> wisp.set_cookie(
                req,
                session.session_cookie_name,
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

fn whoami(current_session: session.CurrentSession) -> Response {
  case current_session {
    session.CurrentSession(user: user, ..) ->
      wisp.ok() |> wisp.json_body(json.to_string(user.user_to_json(user)))
    session.NoSession -> wisp.response(401)
  }
}

import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/option
import gleam/result
import pog
import server/session.{
  type CurrentSession, NoSession, init_session, retrieve_session, session_ttl,
}
import server/sql.{delete_session_where_id}
import server/user_controller
import shared/user
import wisp.{type Request, type Response}
import youid/uuid

pub fn handle_request_login(db: pog.Connection, req: Request) -> Response {
  case req.method, wisp.path_segments(req) {
    Post, ["login"] -> login_user(db, req)
    Post, ["logout"] -> destroy_session(db, req)
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
          case init_session(db, id) {
            Ok(id) ->
              wisp.ok()
              |> wisp.set_cookie(
                req,
                "sessionId",
                uuid.to_string(id),
                wisp.Signed,
                session_ttl,
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

pub fn try_get_session(db: pog.Connection, req: Request) -> CurrentSession {
  case wisp.get_cookie(req, "sessionId", wisp.Signed) {
    Ok(session_id) -> {
      case uuid.from_string(session_id) {
        Ok(id) -> retrieve_session(db, id)
        Error(_) -> {
          wisp.log_error(
            "get_session: Impossible to decode uuid session: " <> session_id,
          )
          NoSession
        }
      }
    }
    Error(Nil) -> NoSession
  }
}

fn destroy_session(db: pog.Connection, req: Request) -> Response {
  let _ = {
    use session_id <- result.try(wisp.get_cookie(req, "sessionId", wisp.Signed))
    use id <- result.try(uuid.from_string(session_id))
    delete_session_where_id(db, id) |> result.map_error(fn(_) { Nil })
  }
  wisp.ok()
  |> wisp.set_cookie(req, "sessionId", "", wisp.PlainText, 0)
}

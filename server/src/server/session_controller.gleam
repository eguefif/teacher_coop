import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/option.{type Option, None, Some}
import pog
import server/session.{
  type CurrentSession, NoSession, init_session, retrieve_session, session_ttl,
}
import server/sql.{GetUserByEmailRow, get_user_by_email}
import server/user_controller.{hash_password}
import shared/user.{UserLoginForm, user_login_form_decoder}
import wisp.{type Request, type Response}
import youid/uuid

pub fn handle_request_login(db: pog.Connection, req: Request) -> Response {
  case req.method, wisp.path_segments(req) {
    Post, ["login"] -> login_user(db, req)
    _, _ -> wisp.not_found()
  }
}

fn login_user(db: pog.Connection, req: Request) -> Response {
  use json <- wisp.require_json(req)
  case decode.run(json, user_login_form_decoder()) {
    Ok(user) -> {
      let assert UserLoginForm(email, password) = user
      case check_password(db, email, password) {
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

fn check_password(
  db: pog.Connection,
  email: String,
  password_check: String,
) -> Option(Int) {
  case get_user_by_email(db, email) {
    Ok(pog.Returned(_row_count, rows)) -> {
      case rows {
        [GetUserByEmailRow(id, _, _, password)] -> {
          let hashed_password = hash_password(password_check)
          case password == hashed_password {
            True -> Some(id)
            False -> None
          }
        }
        _ -> None
      }
    }
    Error(_) -> None
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

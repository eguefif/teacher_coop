import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/option.{type Option, None, Some}
import pog
import server/session.{create_session}
import server/sql.{GetUserByEmailRow, get_user_by_email}
import server/user_controller.{hash_password}
import shared/user.{UserLoginForm, user_login_form_decoder}
import wisp.{type Request, type Response}

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
          case create_session(db, id) {
            Ok(Nil) -> wisp.ok()
            Error(Nil) -> wisp.internal_server_error()
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

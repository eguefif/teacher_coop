import argus
import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/option.{type Option, None, Some}
import pog
import server/sql
import shared/user.{type User, UserForm, user_form_decoder}
import wisp.{type Request, type Response}

pub fn handle_request_user(db: pog.Connection, req: Request) -> Response {
  case req.method, wisp.path_segments(req) {
    Post, ["signup"] -> create_user(db, req)
    _, _ -> wisp.not_found()
  }
}

fn create_user(db: pog.Connection, req: Request) -> Response {
  use json <- wisp.require_json(req)

  case decode.run(json, user_form_decoder()) {
    Ok(user) -> {
      let assert UserForm(_, _, password) = user
      let user = UserForm(..user, password: hash_password(password))
      case create_user_db(db, user) {
        Ok(_) -> wisp.ok()
        Error(_) -> wisp.internal_server_error()
      }
    }
    Error(_) -> wisp.unprocessable_content()
  }
}

pub fn hash_password(password: String) -> String {
  // Safety: we want the process to crash if the hash does not work
  let assert Ok(hashes) =
    argus.hasher() |> argus.hash(password, argus.gen_salt())
  hashes.encoded_hash
}

fn create_user_db(
  db: pog.Connection,
  user: User,
) -> Result(pog.Returned(sql.CreateUserRow), pog.QueryError) {
  let assert UserForm(full_name, email, password) = user
  sql.create_user(db, full_name, email, password)
}

pub fn check_password(
  db: pog.Connection,
  email: String,
  password_check: String,
) -> Option(user.User) {
  case sql.get_user_by_email(db, email) {
    Ok(pog.Returned(
      _,
      [sql.GetUserByEmailRow(id, fullname, email, hashed_password)],
    )) ->
      case argus.verify(hashed_password, password_check) {
        Ok(True) -> {
          let user = user.User(id:, fullname:, email:)
          Some(user)
        }
        Ok(False) | Error(_) -> None
      }
    _ -> None
  }
}

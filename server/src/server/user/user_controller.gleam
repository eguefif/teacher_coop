import app_type.{type App}
import argus
import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/json
import gleam/option.{type Option, None, Some}
import pog
import server/db
import server/env_utils
import server/user/sql
import shared/user.{
  type User, UserForm, UserFormError, user_form_decoder, user_form_error_to_json,
}
import wisp.{type Request, type Response}

pub fn handle_request_user(app: App, req: Request) -> Response {
  case req.method, wisp.path_segments(req) {
    Post, ["signup"] -> create_user(app.db, req)
    _, _ -> wisp.not_found()
  }
}

fn create_user(db: pog.Connection, req: Request) -> Response {
  use json <- wisp.require_json(req)

  case decode.run(json, user_form_decoder()) {
    Ok(user) -> {
      let assert UserForm(_, _, password, _) = user
      let user = UserForm(..user, password: hash_password(password))
      case create_user_db(db, user) {
        Ok(_) -> wisp.ok()
        Error(pog.ConstraintViolated(message, _, _)) ->
          build_constraint_error_response(message)
        Error(_) -> wisp.internal_server_error()
      }
    }
    Error(_) -> wisp.unprocessable_content()
  }
}

fn build_constraint_error_response(message: String) -> wisp.Response {
  let constraint_name = db.extract_constraint_name(message)
  // TODO: We need type to handle constraint error
  let body = case constraint_name {
    "unique_email" -> {
      json.to_string(
        user_form_error_to_json(UserFormError([user.DuplicateEmail])),
      )
    }
    _ -> {
      wisp.log_error(
        "user_controller: constraint name does not exists error: "
        <> constraint_name,
      )
      panic
    }
  }

  wisp.log_info(body)
  wisp.json_response(body, 400)
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
  let assert UserForm(full_name, email, password, school_id) = user
  sql.create_user(db, full_name, email, password, school_id)
}

pub fn check_password(
  db: pog.Connection,
  email: String,
  password_input: String,
) -> Option(user.User) {
  let skip_password = env_utils.skip_password()
  case sql.get_user_by_email(db, email) {
    Ok(pog.Returned(
      _,
      [
        sql.GetUserByEmailRow(
          id,
          fullname,
          email,
          hashed_password,
          db_type,
          _school_id,
        ),
      ],
    )) ->
      case argus.verify(hashed_password, password_input) {
        Ok(True) -> {
          let user =
            user.User(id:, fullname:, email:, type_: case db_type {
              sql.Member -> user.Member
              sql.Admin -> user.Admin
            })
          Some(user)
        }
        // The following is a dev config that allows fast login
        Ok(False) if skip_password -> {
          let user =
            user.User(id:, fullname:, email:, type_: case db_type {
              sql.Member -> user.Member
              sql.Admin -> user.Admin
            })
          Some(user)
        }
        Ok(False) | Error(_) -> None
      }
    _ -> None
  }
}

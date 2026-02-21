import argus
import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/io
import shared/user.{type User, UserForm, user_form_decoder}
import wisp.{type Request, type Response}

pub fn handle_request_user(req: Request) -> Response {
  case req.method, wisp.path_segments(req) {
    Post, ["signup"] -> create_user(req)
    _, _ -> wisp.not_found()
  }
}

fn create_user(req: Request) -> Response {
  use json <- wisp.require_json(req)

  case decode.run(json, user_form_decoder()) {
    Ok(user) -> {
      let assert UserForm(_, _, password) = user
      let user = UserForm(..user, password: hash_password(password))
      io.print("user hash: " <> user.password)
      wisp.ok()
    }
    Error(_) -> wisp.unprocessable_content()
  }
}

fn hash_password(password: String) -> String {
  // Safety: we want the process to crash if the hash does not work
  let assert Ok(hashes) =
    argus.hasher() |> argus.hash(password, argus.gen_salt())
  hashes.encoded_hash
}

fn create_user_db(user: User) -> Bool {
  todo
}

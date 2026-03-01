import gleam/dynamic/decode
import gleam/json

pub type User {
  UserForm(full_name: String, email: String, password: String)
  UserLoginForm(email: String, password: String)
  UserDB(
    id: Int,
    full_name: String,
    email: String,
    password: String,
    confirmed: Bool,
  )
  User(id: Int, fullname: String, email: String)
}

pub fn user_form_decoder() -> decode.Decoder(User) {
  use full_name <- decode.field("full_name", decode.string)
  use email <- decode.field("email", decode.string)
  use password <- decode.field("password", decode.string)
  decode.success(UserForm(full_name:, email:, password:))
}

pub fn user_form_to_json(user: User) -> json.Json {
  let assert UserForm(full_name, email, password) = user
  json.object([
    #("full_name", json.string(full_name)),
    #("email", json.string(email)),
    #("password", json.string(password)),
  ])
}

pub fn user_login_form_decoder() -> decode.Decoder(User) {
  use email <- decode.field("email", decode.string)
  use password <- decode.field("password", decode.string)
  decode.success(UserLoginForm(email:, password:))
}

pub fn user_login_form_to_json(user: User) -> json.Json {
  let assert UserLoginForm(email, password) = user
  json.object([
    #("email", json.string(email)),
    #("password", json.string(password)),
  ])
}

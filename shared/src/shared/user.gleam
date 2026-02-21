import gleam/dynamic/decode
import gleam/json

pub type User {
  User(full_name: String, email: String, password: String)
}

pub fn user_decoder() -> decode.Decoder(User) {
  use full_name <- decode.field("full_name", decode.string)
  use email <- decode.field("email", decode.string)
  use password <- decode.field("password", decode.string)
  decode.success(User(full_name:, email:, password:))
}

pub fn user_to_json(user: User) -> json.Json {
  let User(full_name, email, password) = user
  json.object([
    #("full_name", json.string(full_name)),
    #("email", json.string(email)),
    #("password", json.string(password)),
  ])
}

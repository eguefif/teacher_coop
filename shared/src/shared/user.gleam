import gleam/dynamic/decode
import gleam/json

pub type User {
  UserForm(
    full_name: String,
    email: String,
    password: String,
    school_id: String,
  )
  UserLoginForm(email: String, password: String)
  UserDB(
    id: Int,
    full_name: String,
    email: String,
    password: String,
    confirmed: Bool,
  )
  User(id: Int, fullname: String, email: String, type_: UserT)
}

pub type UserT {
  Admin
  Member
}

pub fn user_form_decoder() -> decode.Decoder(User) {
  use full_name <- decode.field("full_name", decode.string)
  use email <- decode.field("email", decode.string)
  use password <- decode.field("password", decode.string)
  use school_id <- decode.field("school_id", decode.string)
  decode.success(UserForm(full_name:, email:, password:, school_id:))
}

pub fn user_form_to_json(user: User) -> json.Json {
  let assert UserForm(full_name, email, password, school_id) = user
  json.object([
    #("full_name", json.string(full_name)),
    #("email", json.string(email)),
    #("password", json.string(password)),
    #("school_id", json.string(school_id)),
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

pub fn user_decoder() -> decode.Decoder(User) {
  use id <- decode.field("id", decode.int)
  use fullname <- decode.field("fullname", decode.string)
  use email <- decode.field("email", decode.string)
  use type_ <- decode.field(
    "user_type",
    decode.string |> decode.map(fn(user_type) { map_user_type(user_type) }),
  )
  decode.success(User(id:, fullname:, email:, type_:))
}

pub fn user_to_json(user: User) -> json.Json {
  let assert User(id, fullname, email, user_type) = user
  json.object([
    #("id", json.int(id)),
    #("fullname", json.string(fullname)),
    #("email", json.string(email)),
    #("user_type", user_type_to_json(user_type)),
  ])
}

pub fn user_type_to_json(type_: UserT) -> json.Json {
  case type_ {
    Admin -> json.string("admin")
    Member -> json.string("member")
  }
}

fn map_user_type(type_: String) -> UserT {
  case type_ {
    "admin" -> Admin
    "member" -> Member
    _ -> panic
  }
}

//// This module contains the code to run the sql queries defined in
//// `./src/server/user/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/time/timestamp.{type Timestamp}
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_user` query
/// defined in `./src/server/user/sql/create_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateUserRow {
  CreateUserRow(
    id: Int,
    full_name: String,
    email: String,
    password: String,
    user_type: PgUserType,
    school_id: Option(String),
  )
}

/// create user
/// $1: full_name
/// $2: email
/// $3: password
/// $4: school_id
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
  arg_3: String,
  arg_4: String,
) -> Result(pog.Returned(CreateUserRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use full_name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use password <- decode.field(3, decode.string)
    use user_type <- decode.field(4, pg_user_type_decoder())
    use school_id <- decode.field(5, decode.optional(decode.string))
    decode.success(CreateUserRow(
      id:,
      full_name:,
      email:,
      password:,
      user_type:,
      school_id:,
    ))
  }

  "-- create user
-- $1: full_name
-- $2: email
-- $3: password
-- $4: school_id
INSERT INTO users (full_name, email, password, school_id)
    VALUES ($1, $2, $3, $4)
RETURNING
    *;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// delete user by email
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_user(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "-- delete user by email
DELETE FROM users
WHERE email = $1;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_email` query
/// defined in `./src/server/user/sql/get_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByEmailRow {
  GetUserByEmailRow(
    id: Int,
    full_name: String,
    email: String,
    password: String,
    user_type: PgUserType,
    school_id: Option(String),
  )
}

/// get user by email
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_email(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(GetUserByEmailRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use full_name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use password <- decode.field(3, decode.string)
    use user_type <- decode.field(4, pg_user_type_decoder())
    use school_id <- decode.field(5, decode.optional(decode.string))
    decode.success(GetUserByEmailRow(
      id:,
      full_name:,
      email:,
      password:,
      user_type:,
      school_id:,
    ))
  }

  "-- get user by email
SELECT
    *
FROM
    users
WHERE
    email = $1;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_id` query
/// defined in `./src/server/user/sql/get_user_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByIdRow {
  GetUserByIdRow(
    id: Int,
    full_name: String,
    email: String,
    password: String,
    user_type: PgUserType,
    school_id: Option(String),
  )
}

/// Get user by id
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetUserByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use full_name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use password <- decode.field(3, decode.string)
    use user_type <- decode.field(4, pg_user_type_decoder())
    use school_id <- decode.field(5, decode.optional(decode.string))
    decode.success(GetUserByIdRow(
      id:,
      full_name:,
      email:,
      password:,
      user_type:,
      school_id:,
    ))
  }

  "-- Get user by id
SELECT
    *
FROM
    users
WHERE
    id = $1;

"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_session_id` query
/// defined in `./src/server/user/sql/get_user_by_session_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserBySessionIdRow {
  GetUserBySessionIdRow(
    expiration_at: Timestamp,
    id: Int,
    full_name: String,
    email: String,
    user_type: PgUserType,
  )
}

/// Runs the `get_user_by_session_id` query
/// defined in `./src/server/user/sql/get_user_by_session_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_session_id(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(GetUserBySessionIdRow), pog.QueryError) {
  let decoder = {
    use expiration_at <- decode.field(0, pog.timestamp_decoder())
    use id <- decode.field(1, decode.int)
    use full_name <- decode.field(2, decode.string)
    use email <- decode.field(3, decode.string)
    use user_type <- decode.field(4, pg_user_type_decoder())
    decode.success(GetUserBySessionIdRow(
      expiration_at:,
      id:,
      full_name:,
      email:,
      user_type:,
    ))
  }

  "SELECT
    sessions.expiration_at,
    users.id,
    users.full_name,
    users.email,
    users.user_type
FROM
    sessions
    INNER JOIN users ON users.id = sessions.user_id
WHERE
    sessions.id = $1;

"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Enums -------------------------------------------------------------------

/// Corresponds to the Postgres `pg_user_type` enum.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type PgUserType {
  Member
  Admin
}

fn pg_user_type_decoder() -> decode.Decoder(PgUserType) {
  use pg_user_type <- decode.then(decode.string)
  case pg_user_type {
    "member" -> decode.success(Member)
    "admin" -> decode.success(Admin)
    _ -> decode.failure(Member, "PgUserType")
  }
}

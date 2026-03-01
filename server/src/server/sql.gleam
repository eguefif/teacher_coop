//// This module contains the code to run the sql queries defined in
//// `./src/server/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/time/timestamp.{type Timestamp}
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_session` query
/// defined in `./src/server/sql/create_session.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateSessionRow {
  CreateSessionRow(
    id: Uuid,
    user_id: Int,
    created_at: Timestamp,
    expiration_at: Timestamp,
  )
}

/// Runs the `create_session` query
/// defined in `./src/server/sql/create_session.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_session(
  db: pog.Connection,
  arg_1: Int,
  arg_2: Timestamp,
) -> Result(pog.Returned(CreateSessionRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use user_id <- decode.field(1, decode.int)
    use created_at <- decode.field(2, pog.timestamp_decoder())
    use expiration_at <- decode.field(3, pog.timestamp_decoder())
    decode.success(CreateSessionRow(id:, user_id:, created_at:, expiration_at:))
  }

  "INSERT INTO sessions (user_id, expiration_at)
    VALUES ($1, $2)
RETURNING
    *;

"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.timestamp(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_user` query
/// defined in `./src/server/sql/create_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateUserRow {
  CreateUserRow(id: Int, full_name: String, email: String, password: String)
}

/// create user
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
  arg_3: String,
) -> Result(pog.Returned(CreateUserRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use full_name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use password <- decode.field(3, decode.string)
    decode.success(CreateUserRow(id:, full_name:, email:, password:))
  }

  "-- create user
INSERT INTO users (full_name, email, password)
    VALUES ($1, $2, $3)
RETURNING
    *;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_session_where_id` query
/// defined in `./src/server/sql/delete_session_where_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_session_where_id(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM sessions
WHERE id = $1;

"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
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

/// A row you get from running the `get_session_by_user_id` query
/// defined in `./src/server/sql/get_session_by_user_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetSessionByUserIdRow {
  GetSessionByUserIdRow(
    id: Uuid,
    user_id: Int,
    created_at: Timestamp,
    expiration_at: Timestamp,
  )
}

/// Runs the `get_session_by_user_id` query
/// defined in `./src/server/sql/get_session_by_user_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_session_by_user_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetSessionByUserIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use user_id <- decode.field(1, decode.int)
    use created_at <- decode.field(2, pog.timestamp_decoder())
    use expiration_at <- decode.field(3, pog.timestamp_decoder())
    decode.success(GetSessionByUserIdRow(
      id:,
      user_id:,
      created_at:,
      expiration_at:,
    ))
  }

  "SELECT
    *
FROM
    sessions
WHERE
    user_id = $1;

"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_email` query
/// defined in `./src/server/sql/get_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByEmailRow {
  GetUserByEmailRow(id: Int, full_name: String, email: String, password: String)
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
    decode.success(GetUserByEmailRow(id:, full_name:, email:, password:))
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
/// defined in `./src/server/sql/get_user_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByIdRow {
  GetUserByIdRow(id: Int, full_name: String, email: String, password: String)
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
    decode.success(GetUserByIdRow(id:, full_name:, email:, password:))
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
/// defined in `./src/server/sql/get_user_by_session_id.sql`.
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
  )
}

/// Runs the `get_user_by_session_id` query
/// defined in `./src/server/sql/get_user_by_session_id.sql`.
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
    decode.success(GetUserBySessionIdRow(
      expiration_at:,
      id:,
      full_name:,
      email:,
    ))
  }

  "SELECT
    sessions.expiration_at,
    users.id,
    users.full_name,
    users.email
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

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  use bit_array <- decode.then(decode.bit_array)
  case uuid.from_bit_array(bit_array) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> decode.failure(uuid.v7(), "Uuid")
  }
}

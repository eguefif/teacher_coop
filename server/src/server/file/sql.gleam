//// This module contains the code to run the sql queries defined in
//// `./src/server/file/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// A row you get from running the `create_file` query
/// defined in `./src/server/file/sql/create_file.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateFileRow {
  CreateFileRow(
    id: Int,
    filename: String,
    filepath: String,
    user_id: Int,
    file_ingestion_job_id: Option(Int),
  )
}

/// Runs the `create_file` query
/// defined in `./src/server/file/sql/create_file.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_file(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
  arg_3: Int,
) -> Result(pog.Returned(CreateFileRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use filename <- decode.field(1, decode.string)
    use filepath <- decode.field(2, decode.string)
    use user_id <- decode.field(3, decode.int)
    use file_ingestion_job_id <- decode.field(4, decode.optional(decode.int))
    decode.success(CreateFileRow(
      id:,
      filename:,
      filepath:,
      user_id:,
      file_ingestion_job_id:,
    ))
  }

  "INSERT INTO files (filename, filepath, user_id)
    VALUES ($1, $2, $3)
RETURNING
    *;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.int(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `update_ingestion_job_id_file_by_id` query
/// defined in `./src/server/file/sql/update_ingestion_job_id_file_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UpdateIngestionJobIdFileByIdRow {
  UpdateIngestionJobIdFileByIdRow(
    id: Int,
    filename: String,
    filepath: String,
    user_id: Int,
    file_ingestion_job_id: Option(Int),
  )
}

/// Runs the `update_ingestion_job_id_file_by_id` query
/// defined in `./src/server/file/sql/update_ingestion_job_id_file_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_ingestion_job_id_file_by_id(
  db: pog.Connection,
  arg_1: Int,
  arg_2: Int,
) -> Result(pog.Returned(UpdateIngestionJobIdFileByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use filename <- decode.field(1, decode.string)
    use filepath <- decode.field(2, decode.string)
    use user_id <- decode.field(3, decode.int)
    use file_ingestion_job_id <- decode.field(4, decode.optional(decode.int))
    decode.success(UpdateIngestionJobIdFileByIdRow(
      id:,
      filename:,
      filepath:,
      user_id:,
      file_ingestion_job_id:,
    ))
  }

  "UPDATE
    files
SET
    file_ingestion_job_id = $1
WHERE
    id = $2
RETURNING
    *;

"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

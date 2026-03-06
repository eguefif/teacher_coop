//// This module contains the code to run the sql queries defined in
//// `./src/server/file_ingestion/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog

/// A row you get from running the `create_new_job` query
/// defined in `./src/server/file_ingestion/sql/create_new_job.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateNewJobRow {
  CreateNewJobRow(id: Int, filepath: String, state: JobStatus)
}

/// Runs the `create_new_job` query
/// defined in `./src/server/file_ingestion/sql/create_new_job.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_new_job(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(CreateNewJobRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use filepath <- decode.field(1, decode.string)
    use state <- decode.field(2, job_status_decoder())
    decode.success(CreateNewJobRow(id:, filepath:, state:))
  }

  "INSERT INTO file_ingestion_jobs (filepath)
    VALUES ($1)
RETURNING
    *;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_job_to_done_by_id` query
/// defined in `./src/server/file_ingestion/sql/update_job_to_done_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_job_to_done_by_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE
    file_ingestion_jobs
SET
    state = 'done'
WHERE
    id = $1;

"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_job_to_processing_by_id` query
/// defined in `./src/server/file_ingestion/sql/update_job_to_processing_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_job_to_processing_by_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE
    file_ingestion_jobs
SET
    state = 'processing'
WHERE
    id = $1;

"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Enums -------------------------------------------------------------------

/// Corresponds to the Postgres `job_status` enum.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type JobStatus {
  Done
  Processing
  Pending
}

fn job_status_decoder() -> decode.Decoder(JobStatus) {
  use job_status <- decode.then(decode.string)
  case job_status {
    "done" -> decode.success(Done)
    "processing" -> decode.success(Processing)
    "pending" -> decode.success(Pending)
    _ -> decode.failure(Done, "JobStatus")
  }
}

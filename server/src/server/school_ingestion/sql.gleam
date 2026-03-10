//// This module contains the code to run the sql queries defined in
//// `./src/server/school_ingestion/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog

/// A row you get from running the `get_all_hahes` query
/// defined in `./src/server/school_ingestion/sql/get_all_hahes.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAllHahesRow {
  GetAllHahesRow(page: Int, hash: Int)
}

/// Runs the `get_all_hahes` query
/// defined in `./src/server/school_ingestion/sql/get_all_hahes.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_all_hahes(
  db: pog.Connection,
  arg_1: List(Int),
) -> Result(pog.Returned(GetAllHahesRow), pog.QueryError) {
  let decoder = {
    use page <- decode.field(0, decode.int)
    use hash <- decode.field(1, decode.int)
    decode.success(GetAllHahesRow(page:, hash:))
  }

  "SELECT
    *
FROM
    school_ingestion_page_hashes
WHERE
    hash = ANY ($1);

"
  |> pog.query
  |> pog.parameter(pog.array(fn(value) { pog.int(value) }, arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// insert_hashes_buld_array
/// $1: List(Int)
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_hashes_bulk_array(
  db: pog.Connection,
  arg_1: List(Int),
  arg_2: List(Int),
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "-- insert_hashes_buld_array
-- $1: List(Int)
INSERT INTO school_ingestion_page_hashes
SELECT
    *
FROM
    unnest($1::int[], $2::int[]);

"
  |> pog.query
  |> pog.parameter(pog.array(fn(value) { pog.int(value) }, arg_1))
  |> pog.parameter(pog.array(fn(value) { pog.int(value) }, arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

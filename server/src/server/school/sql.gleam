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
  GetAllHahesRow(hash: Int)
}

/// get_all_hahes
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_all_hahes(
  db: pog.Connection,
) -> Result(pog.Returned(GetAllHahesRow), pog.QueryError) {
  let decoder = {
    use hash <- decode.field(0, decode.int)
    decode.success(GetAllHahesRow(hash:))
  }

  "-- get_all_hahes
SELECT
    *
FROM
    school_ingestion_page_hashes;

"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

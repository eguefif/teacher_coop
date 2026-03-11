//// This module contains the code to run the sql queries defined in
//// `./src/server/school/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog

/// A row you get from running the `get_all_hahes` query
/// defined in `./src/server/school/sql/get_all_hahes.sql`.
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

/// A row you get from running the `search_schools` query
/// defined in `./src/server/school/sql/search_schools.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type SearchSchoolsRow {
  SearchSchoolsRow(
    id: String,
    name: String,
    code_departement: String,
    city_name: String,
    score: Float,
  )
}

/// search_schools
/// arg1: String search parameters
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn search_schools(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(SearchSchoolsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use name <- decode.field(1, decode.string)
    use code_departement <- decode.field(2, decode.string)
    use city_name <- decode.field(3, decode.string)
    use score <- decode.field(4, decode.float)
    decode.success(SearchSchoolsRow(
      id:,
      name:,
      code_departement:,
      city_name:,
      score:,
    ))
  }

  "-- search_schools
-- arg1: String search parameters
SELECT
    id,
    name,
    code_departement,
    city_name,
    similarity (search, lower(unaccent ($1))) AS score
FROM
    french_schools
WHERE
    search % lower(unaccent ($1))
ORDER BY
    SCORE DESC
LIMIT 10;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

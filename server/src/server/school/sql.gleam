//// This module contains the code to run the sql queries defined in
//// `./src/server/school/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import pog

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
    word_similarity (lower(unaccent ($1)), search) AS score
FROM
    french_schools
WHERE
    lower(unaccent ($1)) <% search
ORDER BY
    SCORE DESC
LIMIT 20;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `search_schools_by_code_departement` query
/// defined in `./src/server/school/sql/search_schools_by_code_departement.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type SearchSchoolsByCodeDepartementRow {
  SearchSchoolsByCodeDepartementRow(
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
pub fn search_schools_by_code_departement(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
) -> Result(pog.Returned(SearchSchoolsByCodeDepartementRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use name <- decode.field(1, decode.string)
    use code_departement <- decode.field(2, decode.string)
    use city_name <- decode.field(3, decode.string)
    use score <- decode.field(4, decode.float)
    decode.success(SearchSchoolsByCodeDepartementRow(
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
    word_similarity (lower(unaccent ($1)), search) AS score
FROM
    french_schools
WHERE
    lower(unaccent ($1)) <% search
    AND code_departement = $2
ORDER BY
    SCORE DESC
LIMIT 20;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

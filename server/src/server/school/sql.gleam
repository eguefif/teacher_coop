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
  SearchSchoolsRow(name: String, city_name: String, school_type: SchoolType)
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
    use name <- decode.field(0, decode.string)
    use city_name <- decode.field(1, decode.string)
    use school_type <- decode.field(2, school_type_decoder())
    decode.success(SearchSchoolsRow(name:, city_name:, school_type:))
  }

  "-- search_schools
-- arg1: String search parameters
SELECT
    name,
    city_name,
    school_type
FROM
    french_schools
WHERE
    $1 ILIKE name;

"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Enums -------------------------------------------------------------------

/// Corresponds to the Postgres `school_type` enum.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type SchoolType {
  NoType
  TechPro
  GenTechPro
  GenTech
  Professionnal
  Technology
  General
  Middleschool
  ElemKinder
  Kindergarten
  Elementary
}

fn school_type_decoder() -> decode.Decoder(SchoolType) {
  use school_type <- decode.then(decode.string)
  case school_type {
    "no_type" -> decode.success(NoType)
    "tech_pro" -> decode.success(TechPro)
    "gen_tech_pro" -> decode.success(GenTechPro)
    "gen_tech" -> decode.success(GenTech)
    "professionnal" -> decode.success(Professionnal)
    "technology" -> decode.success(Technology)
    "general" -> decode.success(General)
    "middleschool" -> decode.success(Middleschool)
    "elem_kinder" -> decode.success(ElemKinder)
    "kindergarten" -> decode.success(Kindergarten)
    "elementary" -> decode.success(Elementary)
    _ -> decode.failure(NoType, "SchoolType")
  }
}

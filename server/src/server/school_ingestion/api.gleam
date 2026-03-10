import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None, Some}

/// Returns the result from the tailored query to the APIScool
///
///Note that we select the columns we want in the query. The following representation
///is coupled with the select in school_ingestion.gleam
pub fn api_school_from_json(
  json_string: String,
) -> Result(ApiSchoolResponse, json.DecodeError) {
  json.parse(json_string, api_school_response_decoder())
}

pub type ApiSchoolResponse {
  ApiSchoolResponse(total_count: Int, results: List(ApiSchool))
}

pub type ApiSchool {
  ApiSchool(
    identifiant_de_l_etablissement: String,
    nom_etablissement: String,
    type_etablissement: Option(String),
    statut_public_prive: Option(String),
    code_postal: Option(String),
    nom_commune: Option(String),
    code_departement: Option(String),
    code_region: Option(String),
    ecole_maternelle: Option(Int),
    ecole_elementaire: Option(Int),
    voie_generale: Option(String),
    voie_professionnelle: Option(String),
    appartenance_education_prioritaire: Option(String),
  )
}

pub fn api_school_response_to_json(response: ApiSchoolResponse) -> json.Json {
  json.object([
    #("total_count", json.int(response.total_count)),
    #("results", json.array(response.results, api_school_to_json)),
  ])
}

fn api_school_to_json(school: ApiSchool) -> json.Json {
  json.object([
    #(
      "identifiant_de_l_etablissement",
      json.string(school.identifiant_de_l_etablissement),
    ),
    #("nom_etablissement", json.string(school.nom_etablissement)),
    #("type_etablissement", optional_string_to_json(school.type_etablissement)),
    #(
      "statut_public_prive",
      optional_string_to_json(school.statut_public_prive),
    ),
    #("code_postal", optional_string_to_json(school.code_postal)),
    #("nom_commune", optional_string_to_json(school.nom_commune)),
    #("code_departement", optional_string_to_json(school.code_departement)),
    #("code_region", optional_string_to_json(school.code_region)),
    #("ecole_maternelle", optional_int_to_json(school.ecole_maternelle)),
    #("ecole_elementaire", optional_int_to_json(school.ecole_elementaire)),
    #("voie_generale", optional_string_to_json(school.voie_generale)),
    #(
      "voie_professionnelle",
      optional_string_to_json(school.voie_professionnelle),
    ),
    #(
      "appartenance_education_prioritaire",
      optional_string_to_json(school.appartenance_education_prioritaire),
    ),
  ])
}

fn optional_string_to_json(value: Option(String)) -> json.Json {
  case value {
    Some(s) -> json.string(s)
    None -> json.null()
  }
}

fn optional_int_to_json(value: Option(Int)) -> json.Json {
  case value {
    Some(i) -> json.int(i)
    None -> json.null()
  }
}

fn api_school_response_decoder() -> decode.Decoder(ApiSchoolResponse) {
  use total_count <- decode.field("total_count", decode.int)
  use results <- decode.field("results", decode.list(api_school_decoder()))
  decode.success(ApiSchoolResponse(total_count:, results:))
}

fn api_school_decoder() -> decode.Decoder(ApiSchool) {
  use identifiant_de_l_etablissement <- decode.field(
    "identifiant_de_l_etablissement",
    decode.string,
  )
  use nom_etablissement <- decode.field("nom_etablissement", decode.string)
  use type_etablissement <- decode.field(
    "type_etablissement",
    decode.optional(decode.string),
  )
  use statut_public_prive <- decode.field(
    "statut_public_prive",
    decode.optional(decode.string),
  )
  use code_postal <- decode.field("code_postal", decode.optional(decode.string))
  use nom_commune <- decode.field("nom_commune", decode.optional(decode.string))
  use code_departement <- decode.field(
    "code_departement",
    decode.optional(decode.string),
  )
  use code_region <- decode.field("code_region", decode.optional(decode.string))
  use ecole_maternelle <- decode.field(
    "ecole_maternelle",
    decode.optional(decode.int),
  )
  use ecole_elementaire <- decode.field(
    "ecole_elementaire",
    decode.optional(decode.int),
  )
  use voie_generale <- decode.field(
    "voie_generale",
    decode.optional(decode.string),
  )
  use voie_professionnelle <- decode.field(
    "voie_professionnelle",
    decode.optional(decode.string),
  )
  use appartenance_education_prioritaire <- decode.field(
    "appartenance_education_prioritaire",
    decode.optional(decode.string),
  )
  decode.success(ApiSchool(
    identifiant_de_l_etablissement:,
    nom_etablissement:,
    type_etablissement:,
    statut_public_prive:,
    code_postal:,
    nom_commune:,
    code_departement:,
    code_region:,
    ecole_maternelle:,
    ecole_elementaire:,
    voie_generale:,
    voie_professionnelle:,
    appartenance_education_prioritaire:,
  ))
}

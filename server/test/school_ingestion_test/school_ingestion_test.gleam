import gleam/json
import gleam/list
import gleam/option.{None, Some}
import server/school/api
import simplifile

fn load_dataset() -> api.ApiSchoolResponse {
  let assert Ok(json_string) =
    simplifile.read("test/school_ingestion_test/school_dataset.json")
  let assert Ok(response) = api.api_school_from_json(json_string)
  response
}

pub fn parse_total_count_test() {
  let response = load_dataset()
  assert response.total_count == 68_929
}

pub fn parse_results_count_test() {
  let response = load_dataset()
  assert list.length(response.results) == 3
}

pub fn parse_first_school_required_fields_test() {
  let response = load_dataset()
  let assert Ok(school) = list.first(response.results)
  assert school.identifiant_de_l_etablissement == "0250560Y"
  assert school.nom_etablissement == "Ecole élémentaire Centre"
  assert school.type_etablissement == Some("Ecole")
  assert school.statut_public_prive == Some("Public")
}

pub fn parse_first_school_optional_fields_test() {
  let response = load_dataset()
  let assert Ok(school) = list.first(response.results)
  assert school.code_postal == Some("25310")
  assert school.nom_commune == Some("Hérimoncourt")
  assert school.code_departement == Some("025")
  assert school.code_region == Some("27")
}

pub fn parse_first_school_int_fields_test() {
  let response = load_dataset()
  let assert Ok(school) = list.first(response.results)
  assert school.ecole_maternelle == Some(0)
  assert school.ecole_elementaire == Some(1)
  assert school.voie_generale == None
  assert school.voie_professionnelle == None
  assert school.appartenance_education_prioritaire == None
}

pub fn json_roundtrip_test() {
  let response = load_dataset()
  let encoded = json.to_string(api.api_school_response_to_json(response))
  let assert Ok(decoded) = api.api_school_from_json(encoded)
  assert decoded == response
}

pub fn parse_second_school_test() {
  let response = load_dataset()
  let assert Ok(school) = response.results |> list.drop(1) |> list.first
  let school: api.ApiSchool = school
  assert school.identifiant_de_l_etablissement == "0790855A"
  assert school.statut_public_prive == Some("Privé")
  assert school.ecole_maternelle == Some(1)
  assert school.ecole_elementaire == Some(1)
}

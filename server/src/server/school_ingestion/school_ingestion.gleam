import envoy
import gleam/http
import gleam/http/request.{type Request}
import gleam/httpc
import pog
import server/school_ingestion/api

const scheme = http.Http

//const host = "data.education.gouv.fr"
const host = "127.0.0.1:8080"

//const path = "api/explore/v2.1/catalog/datasets/fr-en-annuaire-education/records/"
const path = "/records/fr-en-annuaire-education/records/"

const select = "identifiant_de_l_etablissement,nom_etablissement,type_etablissement,statut_public_prive,code_postal,nom_commune,code_departement,code_region,ecole_maternelle,ecole_elementaire,voie_generale,voie_professionnelle,appartenance_education_prioritaire"

pub fn ingest_french_school(db: pog.Connection) {
  let request = create_request()
}

fn create_request() -> Request(String) {
  let assert Ok(token) = envoy.get("EDUCATION_NATIONAL_TOKEN")
  request.new()
  |> request.set_scheme(scheme)
  |> request.set_host(host)
  |> request.set_path(path)
  |> request.set_method(http.Get)
  |> request.set_cookie("Authorization", "Bearer " <> token)
  |> request.set_query([#("select", select)])
}

pub fn ingest_school_result_page(db, page: String) {
  case api.api_school_from_json(page) {
    Ok(api.ApiSchoolResponse(_, results)) -> create_db_records_from(db, results)
    Error(_) -> panic
  }
}

fn create_db_records_from(db: pog.Connection, results: List(api.ApiSchool)) {
  let sql =
    "
  INSERT INTO french_schools ()
  VALUES
  "
}

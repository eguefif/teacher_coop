import envoy
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{Response}
import gleam/httpc
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import mumu
import pog
import server/school_ingestion/api

const scheme = http.Http

//const host = "data.education.gouv.fr"
const host = "127.0.0.1:8080"

const default_limit = 100

const max_recursion = 20_000

//const path = "api/explore/v2.1/catalog/datasets/fr-en-annuaire-education/records/"
const path = "/records/"

const select = "identifiant_de_l_etablissement,nom_etablissement,type_etablissement,statut_public_prive,code_postal,nom_commune,code_departement,code_region,ecole_maternelle,ecole_elementaire,voie_generale,voie_professionnelle,appartenance_education_prioritaire"

pub fn ingest_french_school(_db: pog.Connection, _ignore_cache: Bool) {
  let #(indexes, hashes, pages) = request_dataset([], [], [], 100_000)
  io.println("indexes: " <> int.to_string(list.length(indexes)))
  io.println("hashes: " <> int.to_string(list.length(hashes)))
  io.println("pages: " <> int.to_string(list.length(pages)))
}

fn request_dataset(
  indexes: List(Int),
  hashes: List(Int),
  pages: List(List(api.ApiSchool)),
  remaining: Int,
) -> #(List(Int), List(Int), List(List(api.ApiSchool))) {
  let last_index = case list.last(indexes) {
    Ok(last_index) -> last_index
    _ -> 0
  }
  case last_index > max_recursion {
    True -> #(indexes, hashes, pages)
    False -> {
      let offset = last_index * default_limit
      let limit = case remaining < default_limit {
        True -> remaining
        False -> default_limit
      }
      let request = create_request(offset, limit)
      case httpc.send(request) {
        Ok(Response(status, _, body)) if status < 300 -> {
          case remaining > 0 {
            True -> {
              let hash = mumu.hash(body)
              let assert Ok(api.ApiSchoolResponse(total_records, new_page)) =
                api.api_school_from_json(body)
              request_dataset(
                list.append(indexes, [last_index + 1]),
                list.append(hashes, [hash]),
                list.append(pages, [new_page]),
                total_records - offset - limit,
              )
            }
            _ -> #(indexes, hashes, pages)
          }
        }
        Ok(Response(status, _, _body)) -> {
          io.println("Http error: " <> string.inspect(status))
          panic
        }
        Error(err) -> {
          io.println("Http error: " <> string.inspect(err))
          panic
        }
      }
    }
  }
}

fn create_request(offset: Int, limit: Int) -> Request(String) {
  let assert Ok(token) = envoy.get("EDUCATION_NATIONAL_TOKEN")
  request.new()
  |> request.set_scheme(scheme)
  |> request.set_host(host)
  |> request.set_path(path)
  |> request.set_method(http.Get)
  |> request.set_cookie("Authorization", "Bearer " <> token)
  |> request.set_query([#("select", select)])
  |> request.set_query([#("limit", int.to_string(limit))])
  |> request.set_query([#("offset", int.to_string(offset))])
}

pub fn ingest_school_result_page(db, page: String) {
  case api.api_school_from_json(page) {
    Ok(api.ApiSchoolResponse(_, results)) -> create_db_records_from(db, results)
    Error(_) -> panic
  }
}

fn create_db_records_from(_db: pog.Connection, _results: List(api.ApiSchool)) {
  let _sql =
    "
  INSERT INTO french_schools ()
  VALUES
  "
}

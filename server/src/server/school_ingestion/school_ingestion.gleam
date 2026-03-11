import envoy
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{Response}
import gleam/httpc
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/string
import mumu
import pog
import server/school_ingestion/api
import server/school_ingestion/sql

const scheme = http.Http

//const host = "data.education.gouv.fr"
const host = "127.0.0.1:8080"

const default_limit = 100

const max_recursion = 69_000

//const path = "api/explore/v2.1/catalog/datasets/fr-en-annuaire-education/records/"
const path = "/records/"

const select = "identifiant_de_l_etablissement,nom_etablissement,type_etablissement,statut_public_prive,code_postal,nom_commune,code_departement,code_region,ecole_maternelle,ecole_elementaire,voie_generale,voie_professionnelle,appartenance_education_prioritaire"

pub fn ingest_french_school(db: pog.Connection, _ignore_cache: Bool) {
  request_dataset(0, 100_000)
  |> persist_hashes_and_filter_out_pages(db, _)
  |> create_or_update_schools(db, _)
}

/// Side effect to the API: retrieve all data per batch of 100 rows
///
/// Returns a list of tupples, each page is associated to its hashe
fn request_dataset(
  offset: Int,
  max_rows: Int,
) -> List(#(Int, List(api.ApiSchool))) {
  case offset >= max_rows || offset > max_recursion {
    True -> []
    False -> {
      let limit = int.min(default_limit, max_rows - offset)
      case httpc.send(create_request(offset, limit)) {
        Ok(Response(status, _, body)) if status < 300 -> {
          let assert Ok(api.ApiSchoolResponse(total_records, page)) =
            api.api_school_from_json(body)
          [
            #(mumu.hash(body), page),
            ..request_dataset(offset + limit, total_records)
          ]
        }
        Ok(Response(status, _, _)) -> {
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
  |> request.set_query([
    #("select", select),
    #("limit", int.to_string(limit)),
    #("offset", int.to_string(offset)),
  ])
}

/// Compares fetched page hashes against the DB to find pages that changed.
///
/// Fetches all known hashes from the DB, filters out pages whose hash already
/// exists (unchanged), then persists the full new hash list via truncate+insert.
/// Returns only the pages that need to be ingested.
fn persist_hashes_and_filter_out_pages(
  db: pog.Connection,
  data: List(#(Int, List(api.ApiSchool))),
) -> List(List(api.ApiSchool)) {
  let pages = case sql.get_all_hahes(db) {
    Ok(pog.Returned(_len, results)) -> {
      let results = results |> list.map(fn(entry) { entry.hash })
      data
      |> list.filter_map(fn(pair) {
        case list.contains(results, pair.0) {
          True -> Error(Nil)
          False -> Ok(pair.1)
        }
      })
    }
    Error(_) -> panic
  }

  io.println("Updating " <> int.to_string(list.length(pages)) <> " rows")
  persist_hahes(db, data)
  pages
}

fn persist_hahes(db: pog.Connection, data: List(#(Int, a))) {
  let hashes = list.map(data, fn(entry) { entry.0 })
  let query = "TRUNCATE school_ingestion_page_hashes;"
  let _ = pog.query(query) |> pog.execute(db)
  let query =
    "
  INSERT INTO school_ingestion_page_hashes (hash)
  select *
  FROM
    unnest($1::bigint[])
  "
  let result =
    pog.query(query)
    |> pog.parameter(pog.array(pog.int, hashes))
    |> pog.execute(db)

  case result {
    Ok(_) -> Nil
    Error(err) -> io.println("Error in perist hash db: " <> string.inspect(err))
  }
}

fn create_or_update_schools(
  db: pog.Connection,
  pages: List(List(api.ApiSchool)),
) {
  case pages {
    [page, ..rest] -> {
      create_or_update_one_page(db, page)
      create_or_update_schools(db, rest)
    }
    [] -> Nil
  }
}

fn create_or_update_one_page(
  db: pog.Connection,
  page: List(api.ApiSchool),
) -> Nil {
  // TODO: 
  // 1. Update table with primary key on school identifiant from the dataset
  // 2. Edit query and define columns to INSERT
  // 3. Edit query with columns to UPDATE
  let query =
    "
  INSERT INTO french_schools (...)
  SELECT 
    list of columns, + add case when to process school type
  FROM jsonb_array_elements($1::jsonb) as elem
  ON CONFLICT school_id
    DO UPDATE SET ....
  "

  let page_json = list_api_school_to_json(page)
  let result =
    pog.query(query)
    |> pog.parameter(pog.text(page_json))
    |> pog.execute(db)

  case result {
    Ok(_) -> io.println("Page ingested")
    Error(err) -> io.println("Error while ingested: " <> string.inspect(err))
  }
  Nil
}

fn list_api_school_to_json(schools: List(api.ApiSchool)) -> String {
  json.array(schools, api.api_school_to_json)
  |> json.to_string
}

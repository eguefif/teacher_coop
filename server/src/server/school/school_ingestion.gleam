import envoy
import gleam/dynamic/decode
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
import server/school/api
import server/school/sql

// TODO: find how to execute the ingestion regularly

const scheme = http.Http

//const host = "data.education.gouv.fr"
const host = "127.0.0.1:8080"

const default_limit = 5000

const max_recursion = 70_000

//const path = "api/explore/v2.1/catalog/datasets/fr-en-annuaire-education/records/"
const path = "/records/"

const select = "identifiant_de_l_etablissement,nom_etablissement,type_etablissement,adresse_1,statut_public_prive,code_postal,nom_commune,code_departement,code_region,ecole_maternelle,ecole_elementaire,voie_generale,voie_professionnelle,voie_technologique,appartenance_education_prioritaire"

pub fn ingest_french_school(db: pog.Connection, _ignore_cache: Bool) {
  io.println("school_ingestion: Starting ingesting french schools...")
  request_dataset(0, 100_000)
  |> persist_hashes_and_filter_out_pages(db, _)
  |> create_or_update_schools(db, _)
  io.println("school_ingestion: Finished ingesting schools")
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
  io.println(
    "Starting page filter with "
    <> int.to_string(list.length(data))
    <> " pages.",
  )
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
) -> Nil {
  io.println(
    "school_ingestion: start persiting in DB "
    <> int.to_string(list.length(pages))
    <> " pages",
  )
  create_or_update_schools_loop(db, pages)
  io.println("school_ingestion: finish persiting in DB ")
}

fn create_or_update_schools_loop(
  db: pog.Connection,
  pages: List(List(api.ApiSchool)),
) -> Nil {
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
  let query =
    "
  INSERT INTO french_schools (id, name, postal_code, city_name,
                              code_departement, code_region, public, rep, school_type)
  SELECT 
    md5((elem->>'identifiant_de_l_etablissement' ||
    (elem->>'nom_etablissement') ||
    COALESCE(elem->>'adresse_1', 'no_address'))) as id,
    elem->>'nom_etablissement' as name,
    elem->>'code_postal' as postal_code,
    elem->>'nom_commune' as city_name,
    elem->>'code_departement' as code_departement,
    elem->>'code_region' as code_region,

    CASE
      WHEN lower(elem->>'statut_public_prive') = 'public' THEN true
      ELSE false
    END as public,

    -- Define the rep type
    CASE
      WHEN lower(elem->>'appartenance_education_prioritaire') = 'rep' THEN 'rep'
      WHEN lower(elem->>'appartenance_education_prioritaire') = 'rep+' THEN 'rep+'
      ELSE 'none'
    END::rep_type as rep,

    -- Define the school type
    CASE
      WHEN lower(elem->>'type_etablissement') = 'collège' THEN 'middleschool'
      WHEN elem->>'ecole_maternelle' = '1' AND
           elem->>'ecole_elementaire' = '1'
                THEN 'elem_kinder'
      WHEN elem->>'ecole_elementaire' = '1' THEN 'elementary'
      WHEN elem->>'ecole_maternelle' = '1' THEN 'kindergarten'
      WHEN elem->>'voie_generale' = '1' AND
           elem->>'voie_technologique' = '1' AND
           elem->>'voie_professionnelle' = '1'
                THEN 'gen_tech_pro'
      WHEN elem->>'voie_generale' = '1'
           AND elem->>'voie_technologique' = '1'
                THEN 'gen_tech'
      WHEN elem->>'voie_professionnelle' = '1' AND
           elem->>'voie_technologique' = '1'
                THEN 'tech_pro'
      WHEN elem->>'voie_generale' = '1' THEN 'general'
      WHEN elem->>'voie_technologique' = '1' THEN 'technology'
      WHEN elem->>'voie_professionnelle' = '1' THEN 'professionnal'
      ELSE 'no_type'
    END::school_type as school_type

  FROM jsonb_array_elements($1::jsonb) as elem
  ON CONFLICT (id)
    DO UPDATE SET 
          name = EXCLUDED.name,
          school_type = EXCLUDED.school_type,
          public = EXCLUDED.public,
          postal_code = EXCLUDED.postal_code,
          city_name = EXCLUDED.city_name,
          code_departement = EXCLUDED.code_departement,
          code_region = EXCLUDED.code_region,
          rep = EXCLUDED.rep
  RETURNING id
  "

  let decoder = {
    use id <- decode.field(0, decode.string)
    decode.success(id)
  }

  let page_json = list_api_school_to_json(page)
  let result =
    pog.query(query)
    |> pog.parameter(pog.text(page_json))
    |> pog.returning(decoder)
    |> pog.execute(db)

  case result {
    Ok(pog.Returned(_, _)) -> Nil
    Error(err) -> io.println("Error while ingested: " <> string.inspect(err))
  }
}

fn list_api_school_to_json(schools: List(api.ApiSchool)) -> String {
  json.array(schools, api.api_school_to_json)
  |> json.to_string
}

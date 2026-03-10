import envoy
import gleam/http
import gleam/http/request.{type Request}
import pog
import rsvp

const scheme = http.Https

const host = "data.education.gouv.fr"

const path = "api/explore/v2.1/catalog/datasets/fr-en-annuaire-education/records/"

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
}

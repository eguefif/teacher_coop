import app_type.{type App}
import gleam/http/request
import gleam/http/response
import gleam/json
import pog
import shared/school.{school_list_to_json}
import wisp

pub fn handle_school(app: App, req: wisp.Request) -> wisp.Response {
  case wisp.path_segments(req) {
    ["school", "search"] -> search_school(app.db, req)
    _ -> wisp.not_found()
  }
}

/// Returns a list of 15 schools based on a search
///
/// Expect query paramters: search
fn search_school(
  db: pog.Connection,
  req: request.Request(wisp.Connection),
) -> response.Response(wisp.Body) {
  use search <- get_search_query(req)
  use results <- get_results(db, search)
  let json_body = school_list_to_json(results) |> json.to_string()
  wisp.json_response(json_body, 200)
}

fn get_search_query(
  req: wisp.Request,
  next: fn(String) -> wisp.Response,
) -> wisp.Response {
  case wisp.get_query(req) {
    [#("search", search)] -> next(search)
    _ -> wisp.bad_request("Invalid Query Parameters: missing search")
  }
}

fn get_results(
  db: pog.Connection,
  search: String,
  value: fn(a) -> b,
) -> response.Response(wisp.Body) {
  todo
}

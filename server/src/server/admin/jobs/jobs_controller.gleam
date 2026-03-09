import app_type.{type App}
import wisp

pub fn handle_jobs(_app: App, req: wisp.Request) -> wisp.Response {
  case req.method, wisp.path_segments(req) {
    _, ["admin", "jobs"] ->
      wisp.response(200) |> wisp.set_body(wisp.Text("Hello"))
    _, _ -> panic
  }
}

import pog
import server/auth/session
import shared/user.{Admin}
import wisp

pub fn handle_admin(
  _db: pog.Connection,
  req: wisp.Request,
  session: session.CurrentSession,
) -> wisp.Response {
  use <- verify_admin(session)
  case req.method, wisp.path_segments(req) {
    _, ["admin"] -> wisp.response(200) |> wisp.set_body(wisp.Text("Hello"))
    _, _ -> panic
  }
}

fn verify_admin(
  session: session.CurrentSession,
  next: fn() -> wisp.Response,
) -> wisp.Response {
  let assert session.CurrentSession(_, _, user.User(_, _, _, type_)) = session
  case type_ {
    Admin -> next()
    _ -> wisp.response(403)
  }
}
// TODO: add middleware handle the user type. Check if admin here

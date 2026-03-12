import gleam/float
import gleam/io
import gleam/time/timestamp
import pog
import server/auth/session.{type CurrentSession, CurrentSession, NoSession}
import wisp.{type Request, type Response}
import youid/uuid

pub fn app_middleware(
  db: pog.Connection,
  req: Request,
  next: fn(#(Request, CurrentSession)) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  let session = get_session(db, req)

  let response = next(#(req, session))
  add_session_to_response(req, response, session)
}

fn get_session(db: pog.Connection, req: Request) -> CurrentSession {
  case wisp.get_cookie(req, session.session_cookie_name, wisp.Signed) {
    Ok(session_id) -> session.try_get_session(db, session_id)
    Error(Nil) -> session.NoSession
  }
}

fn add_session_to_response(
  req: Request,
  response: Response,
  session: CurrentSession,
) -> Response {
  case session {
    CurrentSession(id, expiration, _) -> {
      response
      |> wisp.set_cookie(
        req,
        session.session_cookie_name,
        uuid.to_string(id),
        wisp.Signed,
        expiration_time(expiration),
      )
    }
    _ -> response
  }
}

fn expiration_time(expiration: timestamp.Timestamp) -> Int {
  float.round(timestamp.to_unix_seconds(expiration))
  - float.round(timestamp.to_unix_seconds(timestamp.system_time()))
}

// TODO: Find a better place for the following verify_auth functions

/// This function verify if the user is on a protected route. If so, we 
/// check if they are authenticated
pub fn verify_auth(
  req: Request,
  session: session.CurrentSession,
  next: fn(Request) -> Response,
) -> Response {
  let protected = is_protected_route(req)
  case protected, session {
    True, NoSession -> wisp.response(403)
    _, _ -> next(req)
  }
}

fn is_protected_route(req: Request) -> Bool {
  case wisp.path_segments(req) {
    ["signup"] | ["auth", "login"] -> False
    ["school", ..] -> False
    _ -> {
      io.println("Protected")
      True
    }
  }
}

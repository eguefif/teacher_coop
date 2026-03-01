//// This module handles session creation, retrieval and destruction
//// Session are created in the session_controller
//// Session are retrieved in the session middleware

import gleam/float
import gleam/order
import gleam/result
import gleam/time/duration
import gleam/time/timestamp
import pog
import server/sql.{
  CreateSessionRow, GetUserBySessionIdRow, create_session,
  get_user_by_session_id,
}
import shared/user.{type User, User}
import wisp.{type Request, type Response}
import youid/uuid

pub const session_ttl = 259_200

pub type CurrentSession {
  CurrentSession(
    session_id: uuid.Uuid,
    expiration: timestamp.Timestamp,
    user: User,
  )
  NoSession
}

pub fn init_session(
  db: pog.Connection,
  user_id: Int,
) -> Result(uuid.Uuid, pog.QueryError) {
  case create_session(db, user_id, expires_at()) {
    Ok(pog.Returned(_, rows)) -> {
      case rows {
        [CreateSessionRow(id, _, _, _)] -> Ok(id)
        _ -> panic
      }
    }
    Error(error) -> Error(error)
  }
}

fn expires_at() -> timestamp.Timestamp {
  timestamp.add(timestamp.system_time(), duration.seconds(session_ttl))
}

pub fn retrieve_session(db: pog.Connection, id: uuid.Uuid) -> CurrentSession {
  case get_user_by_session_id(db, id) {
    Ok(pog.Returned(
      _,
      [GetUserBySessionIdRow(session_expires_at, user_id, fullname, email)],
    )) ->
      case
        timestamp.compare(session_expires_at, timestamp.system_time())
        == order.Gt
      {
        True -> {
          let session =
            CurrentSession(
              id,
              session_expires_at,
              User(id: user_id, fullname:, email:),
            )
          try_refresh_session(db, session)
        }
        False -> NoSession
      }
    _ -> NoSession
  }
}

fn try_refresh_session(
  db: pog.Connection,
  session: CurrentSession,
) -> CurrentSession {
  let assert CurrentSession(_, expiration, _) = session
  case should_refresh_session(expiration) {
    True -> refresh_session(db, session)
    False -> session
  }
}

pub fn should_refresh_session(expiration) -> Bool {
  let remaining_time =
    timestamp.difference(expiration, timestamp.system_time())
    |> duration.to_seconds
    |> float.round

  remaining_time < session_ttl / 2
}

fn refresh_session(db, session) -> CurrentSession {
  let assert CurrentSession(id, ..) = session
  let expiration = expires_at()
  let _ = sql.update_session_expiration_at_by_id(db, expiration, id)
  CurrentSession(..session, expiration: expiration)
}

pub fn try_get_session(db: pog.Connection, session_id: String) -> CurrentSession {
  case uuid.from_string(session_id) {
    Ok(id) -> retrieve_session(db, id)
    Error(_) -> {
      wisp.log_error(
        "get_session: Impossible to decode uuid session: " <> session_id,
      )
      NoSession
    }
  }
}

pub fn destroy_session(db: pog.Connection, req: Request) -> Response {
  let _ = {
    use session_id <- result.try(wisp.get_cookie(req, "sessionId", wisp.Signed))
    use id <- result.try(uuid.from_string(session_id))
    sql.delete_session_where_id(db, id) |> result.map_error(fn(_) { Nil })
  }
  wisp.ok()
  |> wisp.set_cookie(req, "sessionId", "", wisp.PlainText, 0)
}

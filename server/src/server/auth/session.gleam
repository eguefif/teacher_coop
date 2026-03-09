//// This module handles session creation, retrieval and destruction
//// Session are created in the session_controller
//// Session are retrieved in the session middleware

import gleam/float
import gleam/io
import gleam/order
import gleam/result
import gleam/time/duration
import gleam/time/timestamp
import pog
import server/auth/sql as auth_sql
import server/user/sql as user_sql
import shared/user.{type User, User}
import wisp.{type Request, type Response}
import youid/uuid

pub const session_ttl = 259_200

pub const session_cookie_name = "session_id"

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
  case auth_sql.create_session(db, user_id, expires_at()) {
    Ok(pog.Returned(_, rows)) -> {
      case rows {
        [auth_sql.CreateSessionRow(id, _, _, _)] -> Ok(id)
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
  wisp.log_info("Session id: " <> uuid.to_string(id))
  case user_sql.get_user_by_session_id(db, id) {
    Ok(pog.Returned(
      _,
      [
        user_sql.GetUserBySessionIdRow(
          session_expires_at,
          user_id,
          fullname,
          email,
          db_type,
        ),
      ],
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
              User(id: user_id, fullname:, email:, type_: case db_type {
                user_sql.Member -> user.Member
                user_sql.Admin -> user.Admin
              }),
            )
          try_refresh_session(db, session)
        }
        False -> {
          wisp.log_info("Error: timestamp")
          NoSession
        }
      }
    _ -> {
      wisp.log_info("Error: No Session")
      NoSession
    }
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
  let _ = auth_sql.update_session_expiration_at_by_id(db, expiration, id)
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
  io.println("Destroying session")
  let _ = {
    use session_id <- result.try(wisp.get_cookie(
      req,
      session_cookie_name,
      wisp.Signed,
    ))
    use id <- result.try(uuid.from_string(session_id))
    auth_sql.delete_session_where_id(db, id) |> result.map_error(fn(_) { Nil })
  }
  wisp.ok()
  |> wisp.set_cookie(req, session_cookie_name, "", wisp.PlainText, 0)
}

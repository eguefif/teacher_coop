//// This module handles session creation and session retrieval
//// Session are created in the session_controller
//// Session are retrieved in the session middleware

import gleam/order
import gleam/time/timestamp
import pog
import server/sql.{
  CreateSessionRow, GetUserBySessionIdRow, create_session,
  get_user_by_session_id,
}
import shared/user.{type User, User}
import youid/uuid

pub const session_ttl = 259_200

pub fn init_session(
  db: pog.Connection,
  user_id: Int,
) -> Result(uuid.Uuid, pog.QueryError) {
  let expires_at = timestamp.from_unix_seconds(session_ttl)
  case create_session(db, user_id, expires_at) {
    Ok(pog.Returned(_, rows)) -> {
      case rows {
        [CreateSessionRow(id, _, _, _)] -> Ok(id)
        _ -> panic
      }
    }
    Error(error) -> Error(error)
  }
}

pub type CurrentSession {
  CurrentSession(
    session_id: uuid.Uuid,
    expiration: timestamp.Timestamp,
    user: User,
  )
  NoSession
}

// TODO: refresh expiration time
pub fn retrieve_session(db: pog.Connection, id: uuid.Uuid) -> CurrentSession {
  case get_user_by_session_id(db, id) {
    Ok(pog.Returned(_, rows)) -> {
      case rows {
        [GetUserBySessionIdRow(session_expires_at, user_id, fullname, email)] -> {
          case
            timestamp.compare(session_expires_at, timestamp.system_time())
            == order.Gt
          {
            True ->
              CurrentSession(
                id,
                session_expires_at,
                User(id: user_id, fullname:, email:),
              )
            False -> NoSession
          }
        }
        _ -> NoSession
      }
    }
    Error(_error) -> NoSession
  }
}

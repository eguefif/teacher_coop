//// This module handles session creation and session retrieval
//// Session are created in the session_controller
//// Session are retrieved in the session middleware

import gleam/io
import pog
import youid/uuid

// TODO: Create migration for session table: id, user_id, expiration_date, created_at
// TODO: Create sql functions to create_session and get_session_by_user_id
pub fn create_session(
  db: pog.Connection,
  user_id: uuid.Uuid,
) -> Result(Nil, Nil) {
  io.println("Creating session: " <> uuid.to_string(user_id))
  Ok(Nil)
}

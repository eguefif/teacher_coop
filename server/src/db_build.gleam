import cigogne
import cigogne/config
import pog
import server/db
import server/user/sql as user_sql
import server/user/user_controller

// TODO: add logic to create a dummy user
pub fn main() {
  let db = db.init_db()
  let _ = reset_db(db)
  let assert Ok(cfg) = config.get("server")
  let assert Ok(engine) = cigogne.create_engine(cfg)
  let assert Ok(_) = cigogne.apply_all(engine)
  create_user(db)
}

fn reset_db(db) {
  let assert Ok(_) =
    pog.query("DROP TABLE IF EXISTS users")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP TABLE IF EXISTS sessions")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("TRUNCATE _migrations RESTART IDENTITY")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP SEQUENCE IF EXISTS users_id_seq")
    |> pog.execute(db)
}

fn create_user(db) {
  let password = user_controller.hash_password("1234!")
  user_sql.create_user(db, "Emmanuel Guefif", "eguefif@fastmail.com", password)
}

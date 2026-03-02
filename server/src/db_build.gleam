import cigogne
import cigogne/config
import pog
import server/db

pub fn main() {
  let db = db.init_db()
  let _ = reset_db(db)
  let assert Ok(cfg) = config.get("server")
  let assert Ok(engine) = cigogne.create_engine(cfg)
  let assert Ok(_) = cigogne.apply_all(engine)
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

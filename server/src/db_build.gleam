import cigogne
import cigogne/config
import gleam/io
import gleam/string
import pog
import server/db
import server/user/user_controller

// TODO: add logic to create a dummy user
pub fn main() {
  let #(db, _) = db.init_db()
  let _ = reset_db(db)
  let assert Ok(cfg) = config.get("server")
  let assert Ok(engine) = cigogne.create_engine(cfg)
  let assert Ok(_) = cigogne.apply_all(engine)
  create_users(db)
}

fn reset_db(db) {
  let assert Ok(_) =
    pog.query("DROP TABLE IF EXISTS users")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP TABLE IF EXISTS sessions")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP TABLE IF EXISTS users")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP TABLE IF EXISTS files")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP TABLE IF EXISTS file_ingestion_jobs")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP TYPE IF EXISTS job_status")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP TYPE IF EXISTS pg_user_type")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("TRUNCATE _migrations RESTART IDENTITY")
    |> pog.execute(db)
  let assert Ok(_) =
    pog.query("DROP SEQUENCE IF EXISTS users_id_seq")
    |> pog.execute(db)
}

fn create_users(db) {
  let password = user_controller.hash_password("1234!")
  let sql = "
  INSERT INTO users (full_name, email, password, user_type)
  VALUES
  ('Emmanuel Guefif', 'eguefif@fastmail.com', '" <> password <> "', 'admin'),
  ('Robert Du Limousin', 'rdl@fastmail.com', '" <> password <> "', 'member');
  "
  case
    pog.query(sql)
    |> pog.execute(db)
  {
    Ok(_) -> io.println("Creating user admin")
    Error(err) -> io.println("Error: " <> string.inspect(err))
  }
}

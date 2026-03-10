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
  let sql =
    "
    DROP TABLE IF EXISTS users;
    DROP TABLE IF EXISTS sessions;
    DROP TABLE IF EXISTS files;
    DROP TABLE IF EXISTS file_ingestion_jobs;
    DROP TYPE IF EXISTS job_status;
    DROP TYPE IF EXISTS pg_user_type;
    DROP TABLE IF EXISTS french_scholes;
    DROP TYPE IF EXISTS school_type;
    DROP TYPE IF EXISTS primary_school_type;
    DROP TYPE IF EXISTS french_highschool_type;
    DROP TYPE IF EXISTS rep_type;
    TRUNCATE _migrations RESTART IDENTITY;
    DROP SEQUENCE IF EXISTS users_id_seq;
    "
  let assert Ok(_) =
    pog.query(sql)
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

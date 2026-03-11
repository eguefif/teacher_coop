import cigogne
import cigogne/config
import gleam/io
import gleam/list
import gleam/string
import pog
import server/db
import server/user/user_controller

// TODO: add logic to create a dummy user
pub fn main() {
  let db = db.init_db_start()
  let _ = reset_db(db)
  let assert Ok(cfg) = config.get("server")
  let assert Ok(engine) = cigogne.create_engine(cfg)
  let assert Ok(_) = cigogne.apply_all(engine)
  create_users(db)
}

fn reset_db(db) {
  // The following string no empty line after and before the "
  "DROP TABLE IF EXISTS users;
    DROP TABLE IF EXISTS sessions;
    DROP TABLE IF EXISTS school_ingestion_page_hashes;
    DROP TABLE IF EXISTS files;
    DROP TABLE IF EXISTS file_ingestion_jobs;
    DROP TYPE IF EXISTS job_status;
    DROP TYPE IF EXISTS pg_user_type;
    DROP TABLE IF EXISTS french_schools;
    DROP TYPE IF EXISTS school_type;
    DROP TYPE IF EXISTS rep_type;
    TRUNCATE _migrations RESTART IDENTITY;
    DROP SEQUENCE IF EXISTS users_id_seq;
    DROP EXTENSION IF EXISTS pg_trgm;
    DROP EXTENSION IF EXISTS unaccent;
    DROP INDEX idx_on_french_schools_name_search;"
  |> string.split("\n")
  |> list.map(fn(query) { pog.query(query) })
  |> list.map(fn(query) { pog.execute(query, db) })
  |> list.each(fn(result) {
    case result {
      Ok(_) -> Nil
      Error(error) -> io.println("Error: DB Reset: " <> string.inspect(error))
    }
  })

  io.println("DB Reset Done")
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

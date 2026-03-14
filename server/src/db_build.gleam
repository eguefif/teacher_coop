import cigogne
import cigogne/config
import gleam/io
import gleam/list
import gleam/string
import pog
import server/db
import server/school/school_ingestion
import server/user/user_controller

// TODO: add logic to create a dummy user
pub fn main() {
  let db = db.init_db_start()
  let _ = reset_db(db)
  let assert Ok(cfg) = config.get("server")
  let assert Ok(engine) = cigogne.create_engine(cfg)
  let assert Ok(_) = cigogne.apply_all(engine)
  create_users(db)
  school_ingestion.ingest_french_school_from_file(
    db,
    "../fr-en-annuaire-education.json",
    70_000,
  )
}

fn reset_db(db) {
  // The following string no empty line after and before the "
  "DROP TABLE users;
    DROP SCHEMA public CASCADE;
    CREATE SCHEMA public;
    GRANT ALL ON SCHEMA public TO public;
    DROP EXTENSION IF EXISTS pg_trgm;
    DROP EXXTENSION IF EXISTS unaccent;"
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

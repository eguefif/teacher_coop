import server/db
import server/school_ingestion/school_ingestion as si

pub fn main() {
  let #(db, _) = db.init_db()
  si.ingest_french_school(db, False)
}

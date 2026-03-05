import gleam/list
import pog
import server/auth/session
import server/file/sql
import shared/user.{User}
import simplifile
import wisp
import youid/uuid

type File {
  Pdf(data: BitArray)
  Docx(data: BitArray)
  Pptx(data: BitArray)
  Odt(data: BitArray)
  Odp(data: BitArray)
}

pub fn handle_file(
  db: pog.Connection,
  req: wisp.Request,
  session: session.CurrentSession,
) -> wisp.Response {
  case wisp.path_segments(req) {
    ["file", "upload"] -> upload_file(db, req, session)
    _ -> wisp.not_found()
  }
}

// TODO: we receive in the  content-type the file typ
// In the body the byte. I added simplifile
// We need to get the to
// - [X] Retrieve the type and file
// - [X] Add a new table files
//       * id
//       * user_id
//       * format
//       * ingestion job id
//       * path
// - [ ] Create an entry in the DB and link to the user
// - [ ] Retrieve the byte and write it on disck
// - [ ] Save using the type with a semi random name
// Step 2
// - [X] Add a queue table for ingestion in the DB
//       * id
//       * file path
//       * file id
//       * Job status: pending, processing, processed
// - [ ] Schedule an ingestion job link to the file
// - [ ] Have a job that check
fn upload_file(
  db: pog.Connection,
  req: wisp.Request,
  session: session.CurrentSession,
) -> wisp.Response {
  use body <- wisp.require_bit_array_body(req)
  use file <- get_content_file(req, body)
  use file_metadata <- write_file_in_disk(file)
  use file_id <- add_file_in_db(file_metadata, db, session)
  schedule_ingestion_job(file_id)
}

fn schedule_ingestion_job(file_id: Int) -> response.Response(wisp.Body) {
  todo
}

fn write_file_in_disk(
  file: File,
  next: fn(#(String, String)) -> wisp.Response,
) -> wisp.Response {
  let filename = create_filename(file)
  let filepath = "./assets/" <> filename
  case simplifile.write_bits(filepath, file.data) {
    Ok(_) -> next(#(filename, filepath))
    Error(_) -> wisp.internal_server_error()
  }
}

fn create_filename(file: File) -> String {
  let file_start = uuid.v7() |> uuid.to_string()
  let file_extension = case file {
    Pdf(_) -> ".pdf"
    Docx(_) -> ".docx"
    Pptx(_) -> "pptx"
    Odt(_) -> "odt"
    Odp(_) -> "odp"
  }
  file_start <> file_extension
}

fn add_file_in_db(
  file_metadata: #(String, String),
  db: pog.Connection,
  session: session.CurrentSession,
  next: fn(Int) -> wisp.Response,
) -> wisp.Response {
  let #(filename, filepath) = file_metadata
  let assert session.CurrentSession(_, _, User(id, ..)) = session
  case sql.create_file(db, filename, filepath, id) {
    Ok(pog.Returned(_, [sql.CreateFileRow(id, ..)])) -> next(id)
    _ -> wisp.internal_server_error()
  }
}

fn get_content_file(
  req: wisp.Request,
  body: BitArray,
  next: fn(File) -> wisp.Response,
) -> wisp.Response {
  use content_type <- get_content_type(req)
  case content_type {
    "pdf" -> next(Pdf(body))
    "docx" -> next(Docx(body))
    "pptx" -> next(Pptx(body))
    "odt" -> next(Odt(body))
    "odp" -> next(Odp(body))
    _ -> wisp.unprocessable_content()
  }
}

fn get_content_type(
  req: wisp.Request,
  next: fn(String) -> wisp.Response,
) -> wisp.Response {
  case req.headers |> list.key_find("content-type") {
    Ok(content_type) -> next(content_type)
    Error(_) -> wisp.unprocessable_content()
  }
}

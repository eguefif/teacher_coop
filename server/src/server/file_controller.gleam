import gleam/list
import gleam/option
import gleam/result
import pog
import server/session
import wisp

pub fn handle_file(
  db: pog.Connection,
  req: wisp.Request,
  session: session.CurrentSession,
) -> wisp.Response {
  case session {
    session.CurrentSession(..) -> dispatch(db, req)
    session.NoSession -> wisp.response(401)
  }
}

type File {
  Pdf(data: BitArray)
  Docx(data: BitArray)
  Pptx(data: BitArray)
  Odt(data: BitArray)
  Odp(data: BitArray)
}

// TODO: we receive in the  content-type the file typ
// In the body the byte. I added simplifile
// We need to get the to
// - [X] Retrieve the type and file
// - [ ] Add a new table files
//       * id
//       * user_id
//       * format
//       * ingestion job id
//       * path
// - [ ] Create an entry in the DB and link to the user
// - [ ] Retrieve the byte and write it on disck
// - [ ] Save using the type with a semi random name
// Step 2
// - [ ] Add a queue table for ingestion in the DB
//       * id
//       * file path
//       * file id
//       * Job status: pending, processing, processed
// - [ ] Schedule an ingestion job link to the file
// - [ ] Have a job that check
fn dispatch(db, req) -> wisp.Response {
  use body <- wisp.require_bit_array_body(req)
  use file <- get_content_file(req, body)
  wisp.ok()
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

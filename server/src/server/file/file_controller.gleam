import gleam/list
import gleam/string
import pog
import server/auth/session
import server/file/sql
import server/file_ingestion/sql as ingestion_sql
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

pub fn handle_request_file(
  db: pog.Connection,
  req: wisp.Request,
  session: session.CurrentSession,
) -> wisp.Response {
  case wisp.path_segments(req) {
    ["file", "upload"] -> upload_file(db, req, session)
    _ -> wisp.not_found()
  }
}

fn upload_file(
  db: pog.Connection,
  req: wisp.Request,
  session: session.CurrentSession,
) -> wisp.Response {
  use body <- wisp.require_bit_array_body(req)
  use file <- get_content_file(req, body)
  use file_metadata <- write_file_in_disk(file)
  use #(file_id, file_path) <- add_file_in_db(file_metadata, db, session)
  use job_id <- schedule_ingestion_job(db, file_path)
  update_file_db_with_job_id(db, file_id, job_id)
}

fn schedule_ingestion_job(
  db: pog.Connection,
  file_path: String,
  next: fn(Int) -> wisp.Response,
) -> wisp.Response {
  case ingestion_sql.create_new_job(db, file_path) {
    Ok(pog.Returned(_, [ingestion_sql.CreateNewJobRow(id, _, _)])) -> next(id)
    _ -> wisp.internal_server_error()
  }
}

fn update_file_db_with_job_id(
  db: pog.Connection,
  file_id: Int,
  job_id: Int,
) -> wisp.Response {
  let assert Ok(_) = sql.update_ingestion_job_id_file_by_id(db, job_id, file_id)
  wisp.ok()
}

fn write_file_in_disk(
  file: File,
  next: fn(#(String, String)) -> wisp.Response,
) -> wisp.Response {
  let filename = create_filename(file)
  let assert Ok(path) = wisp.priv_directory("server")
  let filepath = path <> filename
  case simplifile.write_bits(filepath, file.data) {
    Ok(_) -> next(#(filename, filepath))
    Error(e) -> {
      wisp.log_error(
        "file_controller: error: impossible to write file: "
        <> string.inspect(e),
      )
      wisp.internal_server_error()
    }
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
  next: fn(#(Int, String)) -> wisp.Response,
) -> wisp.Response {
  let #(filename, filepath) = file_metadata
  let assert session.CurrentSession(_, _, User(id, ..)) = session
  case sql.create_file(db, filename, filepath, id) {
    Ok(pog.Returned(_, [sql.CreateFileRow(id, ..)])) -> next(#(id, filepath))
    _ -> wisp.internal_server_error()
  }
}

fn get_content_file(
  req: wisp.Request,
  body: BitArray,
  next: fn(File) -> wisp.Response,
) -> wisp.Response {
  use content_type <- get_content_type(req)
  case string.split(content_type, "/") {
    [_, "pdf"] -> next(Pdf(body))
    [_, "docx"] -> next(Docx(body))
    [_, "pptx"] -> next(Pptx(body))
    [_, "odt"] -> next(Odt(body))
    [_, "odp"] -> next(Odp(body))
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

import g18n
import gleam/dynamic
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp

// Model -----------------------------------------------------------------------------------------
pub type Model {
  File(file: decode.Dynamic, data: BitArray)
}

pub fn init() -> Model {
  File(dynamic.nil(), <<>>)
}

// Update -----------------------------------------------------------------------------------------
pub type Msg {
  UserSelectedFile(file: decode.Dynamic, mime: String)
  BrowserLoadedFile(data: BitArray, mime: String)
  ServerReceivedFile(Result(String, rsvp.Error))
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserSelectedFile(file, mime) -> #(
      File(..model, file:),
      read_file(file, mime),
    )
    BrowserLoadedFile(data, mime) -> #(
      File(..model, data:),
      upload_file(data, mime),
    )
    ServerReceivedFile(_) -> #(model, effect.none())
  }
}

fn read_file(file: dynamic.Dynamic, mime: String) -> effect.Effect(Msg) {
  use dispatch <- effect.from
  do_read_file(file, fn(bits) { dispatch(BrowserLoadedFile(bits, mime)) })
}

@external(javascript, "./read_file.mjs", "read_file")
fn do_read_file(file: dynamic.Dynamic, dispatch: fn(BitArray) -> Nil) -> Nil

fn upload_file(data: BitArray, mime: String) -> Effect(Msg) {
  let assert Ok(req) = request.to("/api/file/upload")
  let req =
    req
    |> request.set_method(http.Post)
    |> request.set_header("content-type", mime)
    |> request.set_body(data)
  rsvp.send_bits(req, rsvp.expect_text(ServerReceivedFile))
}

// View -----------------------------------------------------------------------------------------

pub fn view(
  translator: g18n.Translator,
  msg_wrapper: fn(Msg) -> msg,
  extensions: List(String),
) -> Element(msg) {
  let styles = [
    #("display", "flex"),
    #("flex-direction", "column"),
    #("gap", "12px"),
  ]
  html.div([attribute.styles(styles)], [
    html.label([attribute.for("filepath")], [
      html.text(g18n.translate(translator, "workspace.fileform.filepath_label")),
    ]),
    html.input([
      attribute.type_("file"),
      attribute.id("filepath"),
      attribute.accept(extensions),
      filepath_on_change(msg_wrapper),
    ]),
  ])
}

fn filepath_on_change(msg_wrapper) -> attribute.Attribute(msg) {
  let decoder = {
    use file <- decode.subfield(["target", "files", "0"], decode.dynamic)
    use mime <- decode.subfield(["target", "files", "0", "type"], decode.string)
    decode.success(msg_wrapper(UserSelectedFile(file, mime)))
  }
  event.on("change", decoder)
}

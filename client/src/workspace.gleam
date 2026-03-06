import forms/filepath
import g18n
import gleam/http
import gleam/http/request
import gleam/option
import js/window as js
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import reusables/button
import rsvp

const extensions = [".pdf", ".docx", ".xlsx", ".pptx", ".odt", ".ods", ".odp"]

// Model ---------------------------------------------------------------------------------------

pub type Model {
  FileForm(file: filepath.Model, error: String, valid: Bool)
}

pub fn fileform_init() {
  FileForm(filepath.init(), "", False)
}

// Update ---------------------------------------------------------------------------------------
pub type Msg {
  UserSubmitedFileForm(List(#(String, String)))
  BrowserSentFile(Result(String, rsvp.Error))
  FilePathMsg(filepath.Msg)
}

pub fn update(
  _translator: g18n.Translator,
  model: Model,
  msg: Msg,
  //wrapper_msg: fn(Msg) -> msg,
) -> #(Model, Effect(Msg)) {
  case msg {
    UserSubmitedFileForm(_) -> #(
      model,
      upload_file(model.file.data, model.file.filetype),
    )
    BrowserSentFile(Ok(_)) -> #(model, effect.none())
    BrowserSentFile(Error(_)) -> #(model, effect.none())
    FilePathMsg(msg) -> filepath_update(model.file, msg)
  }
}

fn filepath_update(
  file: filepath.Model,
  msg: filepath.Msg,
) -> #(Model, Effect(Msg)) {
  let #(model, effect) = filepath.update(file, msg)
  #(FileForm(model, "", False), effect |> effect.map(FilePathMsg))
}

fn upload_file(data: BitArray, mime: String) -> Effect(Msg) {
  let base_url = js.base_url()
  let assert Ok(req) = request.to(base_url <> "/api/file/upload")
  let req =
    req
    |> request.set_method(http.Post)
    |> request.set_header("content-type", mime)
    |> request.set_body(data)
  rsvp.send_bits(req, rsvp.expect_text(BrowserSentFile))
}

// View ---------------------------------------------------------------------------------------

pub fn view(
  translator: g18n.Translator,
  fileform: Model,
  msg_wrapper: fn(Msg) -> msg,
) -> Element(msg) {
  let wrapper_styles = [
    #("display", "flex"),
    #("flex-direction", "column"),
    #("gap", "16px"),
  ]
  html.div([attribute.styles(wrapper_styles)], [
    html.h1([], [
      html.text(g18n.translate(translator, "workspace.title")),
    ]),
    fileform_view(translator, fileform, msg_wrapper),
  ])
}

fn fileform_view(
  translator: g18n.Translator,
  _fileform: Model,
  msg_wrapper: fn(Msg) -> msg,
) -> Element(msg) {
  let styles = [
    #("display", "flex"),
    #("flex-direction", "column"),
    #("gap", "12px"),
  ]
  html.form(
    [
      event.on_submit(fn(msg) { msg_wrapper(UserSubmitedFileForm(msg)) }),
      attribute.styles(styles),
    ],
    [
      filepath.view(
        translator,
        fn(msg) { msg_wrapper(FilePathMsg(msg)) },
        extensions,
      ),
      button.button(
        option.None,
        g18n.translate(translator, "workspace.fileform.submit"),
        "submit",
      ),
    ],
  )
}

import forms/filepath
import g18n
import gleam/io
import gleam/option
import gleam/string
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import reusables/button

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
  UserSubmittedFileForm
  BrowserSentFile(String)
  FilePathMsg(filepath.Msg)
}

pub fn update(
  _translator: g18n.Translator,
  model: Model,
  msg: Msg,
  //wrapper_msg: fn(Msg) -> msg,
) -> #(Model, Effect(Msg)) {
  case msg {
    UserSubmittedFileForm -> update_fileform(model)
    BrowserSentFile(_response) -> #(model, effect.none())
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

fn update_fileform(model: Model) -> #(Model, Effect(Msg)) {
  io.println(
    "File: "
    <> string.inspect(model.file.file)
    <> "\n"
    <> string.inspect(model.file.data),
  )
  #(model, effect.none())
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
  html.form([attribute.styles(styles)], [
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
  ])
}

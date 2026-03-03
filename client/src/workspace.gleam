import g18n
import gleam/list
import gleam/string
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import reusables/input

// Model ---------------------------------------------------------------------------------------

pub type Model {
  FileForm(filepath: String, error_filepath: String, valid_filepath: Bool)
}

pub fn fileform_init() {
  FileForm("", "", False)
}

// Update ---------------------------------------------------------------------------------------
pub type Msg {
  UserUpdatedFilepathInput(String)
  UserFinishedUpdatedFilepathInput
  UserSubmittedFileForm
}

pub fn update(
  translator: g18n.Translator,
  model: Model,
  msg: Msg,
  //wrapper_msg: fn(Msg) -> msg,
) -> #(Model, Effect(Msg)) {
  case msg {
    UserUpdatedFilepathInput(filepath) -> #(
      FileForm(..model, filepath:),
      effect.none(),
    )
    UserFinishedUpdatedFilepathInput -> #(
      validate_filepath(translator, model),
      effect.none(),
    )
    UserSubmittedFileForm -> #(model, effect.none())
  }
}

fn validate_filepath(translator: g18n.Translator, model: Model) -> Model {
  let extensions = [".pdf", ".docx", ".xlsx", ".pptx", ".odt", ".ods", ".odp"]
  let FileForm(filepath, _, _) = model
  case string.split(filepath, ".") {
    [_, extension] -> {
      case list.contains(extensions, extension) {
        True -> FileForm(filepath, "", True)
        False ->
          FileForm(
            filepath,
            g18n.translate(
              translator,
              "workspace.fileform.format_error: "
                <> string.join(extensions, ", "),
            ),
            False,
          )
      }
    }
    _ ->
      FileForm(
        filepath,
        g18n.translate(translator, "workspace.fileform.no_extension_error"),
        False,
      )
  }
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
  fileform: Model,
  msg_wrapper,
) -> Element(msg) {
  html.form([], [
    input.input(
      fileform.filepath,
      fileform.error_filepath,
      fileform.valid_filepath,
      fn(v) { msg_wrapper(UserUpdatedFilepathInput(v)) },
      msg_wrapper(UserFinishedUpdatedFilepathInput),
      "file",
      "filepath",
      g18n.translate(translator, "workspace.fileform.filepath_label"),
    ),
  ])
}

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn input(
  text: String,
  error: String,
  is_valid is_valid: Bool,
  on_focus on_focus: fn(String) -> msg,
  on_blur on_blur: Option(msg),
  is type_: String,
  name name: String,
  label label: String,
) -> Element(msg) {
  let has_error = string.length(error) > 0
  let has_input = string.length(text) > 0
  let input_class = case is_valid, has_error, has_input {
    _, True, True -> "input-error"
    True, False, True -> "input-valid"
    _, _, _ -> ""
  }

  let row_styles = [
    #("position", "relative"),
    #("display", "flex"),
    #("width", "400px"),
    #("flex-direction", "row"),
    #("align-items", "center"),
  ]

  html.div([input_styles()], [
    html.label([attribute.for(name)], [
      html.text(label),
    ]),
    html.div([attribute.styles(row_styles)], [
      html.input([
        event.on_input(on_focus),
        event.on_input(on_focus),
        case on_blur {
          Some(on_blur) -> event.on_blur(on_blur)
          None -> attribute.none()
        },
        attribute.type_(type_),
        attribute.id(name),
        attribute.value(text),
        attribute.class(input_class),
      ]),
      html.p(
        [
          attribute.class(case is_valid && has_input {
            True -> "input-valid-message visible"
            False -> "input-valid-message"
          }),
        ],
        [],
      ),
    ]),
    html.div(
      [
        attribute.class(case has_error && has_input {
          True -> "input-error-message visible"
          False -> "input-error-message"
        }),
      ],
      [html.text(error)],
    ),
  ])
}

pub fn input_styles() -> attribute.Attribute(msg) {
  attribute.styles([
    #("position", "relative"),
    #("display", "flex"),
    #("max-width", "300px"),
    #("flex-direction", "column"),
    #("gap", "4px"),
    #("padding-bottom", "2.5rem"),
  ])
}

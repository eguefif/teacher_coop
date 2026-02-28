import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

// TODO: Improve styling, the form is not centered with the button
pub fn input(
  text: String,
  error: String,
  is_valid is_valid: Bool,
  on_focus on_focus: fn(String) -> msg,
  on_blur on_blur: msg,
  is type_: String,
  name name: String,
  label label: String,
) -> Element(msg) {
  let wrapper_styles = [
    #("display", "flex"),
    #("flex-direction", "column"),
    #("gap", "4px"),
  ]
  let #(input_style, message_element) = case is_valid, string.length(error) > 0 {
    _, True -> #(
      "input-error",
      html.p([attribute.class("input-error-message visible")], [
        html.text(error),
      ]),
    )
    True, False -> #(
      "input-valid",
      html.p([attribute.class("input-valid-message visible")], []),
    )
    False, False -> #("", html.p([], []))
  }

  let row_styles = [
    #("display", "flex"),
    #("flex-direction", "row"),
    #("align-items", "center"),
    #("gap", "12px"),
  ]

  html.div([attribute.styles(wrapper_styles)], [
    html.label([attribute.for(name)], [
      html.text(label),
    ]),
    html.div([attribute.styles(row_styles)], [
      html.input([
        event.on_input(on_focus),
        event.on_blur(on_blur),
        attribute.type_(type_),
        attribute.id(name),
        attribute.value(text),
        attribute.class(input_style),
      ]),
      message_element,
    ]),
  ])
}

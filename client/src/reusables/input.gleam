import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import shared/form.{type Form}

pub fn input(
  form: Form,
  is type_: String,
  name name: String,
  label label: String,
) -> Element(msg) {
  let styles = [
    #("display", "flex"),
    #("flex-direction", "row"),
    #("justify-content", "space-between"),
    #("gap", "12px"),
  ]

  html.div([attribute.styles(styles)], [
    html.label([], [
      html.text(label),
    ]),
    html.input([]),
  ])
}

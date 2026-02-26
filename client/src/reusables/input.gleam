import formal/form.{type Form}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn input(
  form: Form(form),
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
    html.label([attribute.for(name)], [
      html.text(label),
    ]),
    html.input([attribute.type_(type_), attribute.id(name)]),
  ])
}

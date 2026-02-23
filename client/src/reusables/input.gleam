import lustre/element.{type Element}
import lustre/element/html
import shared/form.{type Form}

pub fn input(
  form: Form,
  is type_: String,
  name name: String,
  label label: String,
) -> Element(msg) {
  html.div([], [html.label([], [html.text(label), html.text(" :")])])
}

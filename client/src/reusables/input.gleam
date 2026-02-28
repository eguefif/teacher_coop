import formal/form.{type Form}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn input(
  _form: Form(form),
  event event: fn(String) -> msg,
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
    html.input([
      // Is the problem because I nested Msg type like Msg(SignupMSG(String)) ?
      event.on_input(event),
      attribute.type_(type_),
      attribute.id(name),
    ]),
  ])
}

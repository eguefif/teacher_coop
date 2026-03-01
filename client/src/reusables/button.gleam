import gleam/option.{type Option}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

//<!-- From Uiverse.io by TaniaDou --> 
//<div class="button">Button<span class="button-border"></span></div>

pub fn button(event: Option(msg), label: String) -> Element(msg) {
  case event {
    option.Some(event) ->
      html.div([attribute.class("button"), event.on_click(event)], [
        html.text(label),
        html.span([attribute.class("button-border")], []),
      ])
    option.None ->
      html.div([attribute.class("button")], [
        html.text(label),
        html.span([attribute.class("button-border")], []),
      ])
  }
}

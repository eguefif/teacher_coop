import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// TODO: find a way to have a css file with variables
// TODO: Create an input style
pub fn input(attributes: List(Attribute(msg))) -> Element(msg) {
  let styles = [#()]
  html.input([attribute.class("lustre-ui-input"), ..attributes])
}

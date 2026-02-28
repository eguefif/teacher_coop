import g18n
import lustre/attribute
import lustre/element/html

pub fn view(translator: g18n.Translator) {
  let wrapper_styles = [#("max-width", "840px"), #("margin", "16px auto")]
  let input_styles = [
    #("width", "100%"),
    #("padding", "16px 24px"),
    #("font-size", "1.1rem"),
    #("border", "2px solid var(--color-surface)"),
    #("border-radius", "16px"),
    #("outline", "none"),
    #("box-sizing", "border-box"),
  ]

  html.div([attribute.styles(wrapper_styles)], [
    html.input([
      attribute.styles(input_styles),
      attribute.placeholder(g18n.translate(translator, "search.placeholder")),
    ]),
  ])
}

import g18n
import gleam/option
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import shared/user

pub fn view(
  translator: g18n.Translator,
  user: option.Option(user.User),
) -> Element(msg) {
  let styles = [
    #("background", "var(--color-surface)"),
    #("display", "flex"),
    #("flex-direction", "row"),
    #("justify-content", "space-between"),
    #("align-items", "center"),
    #("width", "840px"),
    #("border-radius", "40px"),
    #("margin", "16px auto"),
    #("padding", "12px 24px"),
  ]

  html.div([attribute.styles(styles)], [
    html.h2([], [
      html.a([attribute.href("/")], [
        html.text(g18n.translate(translator, "nav.brand")),
      ]),
    ]),
    case user {
      option.Some(_) -> user_header_button(translator)
      option.None -> header_button(translator)
    },
  ])
}

fn header_button(translator: g18n.Translator) -> Element(msg) {
  let styles = [
    #("background", "var(--color-surface)"),
    #("display", "flex"),
    #("flex-direction", "row"),
    #("gap", "20px"),
  ]
  html.div([attribute.styles(styles)], [
    html.a([attribute.href("/")], [
      html.text(g18n.translate(translator, "nav.search")),
    ]),
    html.a([attribute.href("/signup")], [
      html.text(g18n.translate(translator, "nav.signup")),
    ]),
    html.a([attribute.href("/login")], [
      html.text(g18n.translate(translator, "nav.login")),
    ]),
  ])
}

fn user_header_button(translator: g18n.Translator) -> Element(msg) {
  let styles = [
    #("background", "var(--color-surface)"),
    #("display", "flex"),
    #("flex-direction", "row"),
    #("gap", "20px"),
  ]
  html.div([attribute.styles(styles)], [
    html.a([attribute.href("/")], [
      html.text(g18n.translate(translator, "nav.search")),
    ]),
    html.a([attribute.href("/workspace")], [
      html.text(g18n.translate(translator, "nav.workspace")),
    ]),
    html.a([attribute.href("/logout")], [
      html.text(g18n.translate(translator, "nav.logout")),
    ]),
  ])
}

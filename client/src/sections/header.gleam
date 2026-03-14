import g18n
import gleam/option
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import shared/user

pub type Msg {
  Logout
}

pub fn view(
  translator: g18n.Translator,
  user: option.Option(user.User),
  msg_wrapper: fn(Msg) -> msg,
) -> Element(msg) {
  html.div([attribute.class("header")], [
    header_style(),
    html.h2([], [
      html.a([attribute.href("/")], [
        html.text(g18n.translate(translator, "nav.brand")),
      ]),
    ]),
    case user {
      option.Some(_) -> user_header_button(translator, msg_wrapper)
      option.None -> header_button(translator)
    },
  ])
}

fn header_button(translator: g18n.Translator) -> Element(msg) {
  html.nav([attribute.class("header-nav")], [
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

fn user_header_button(
  translator: g18n.Translator,
  msg_wrapper: fn(Msg) -> msg,
) -> Element(msg) {
  html.nav([attribute.class("header-nav")], [
    html.a([attribute.href("/")], [
      html.text(g18n.translate(translator, "nav.search")),
    ]),
    html.a([attribute.href("/workspace")], [
      html.text(g18n.translate(translator, "nav.workspace")),
    ]),
    html.a([attribute.href("/logout"), event.on_click(msg_wrapper(Logout))], [
      html.text(g18n.translate(translator, "nav.logout")),
    ]),
  ])
}

fn header_style() -> Element(msg) {
  html.style(
    [],
    "
    .header {
      background: var(--color-surface);
      display: flex;
      flex-direction: row;
      justify-content: space-around;
      align-items: center;
      width: 90%;
      max-width: 800px;
      border-radius: 40px;
      margin: auto;
      padding: 12px;
    }
    .header-nav {
      background: var(--color-surface);
      display: flex;
      flex-direction: row;
      gap: 20px;
      margin: 4px;
    }
    @media (max-width: 550px) {
      .header {
        padding: 12px 4px;
      }
      .header-nav {
        flex-direction: column;
        gap: 12px;
      }
      .header h2 {
        font-size: 1.1rem;
      }
    }
    ",
  )
}

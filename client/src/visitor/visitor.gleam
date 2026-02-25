//import formal/form
import gleam/http/response.{type Response}
import gleam/regexp
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import reusables/input.{input}
import rsvp
import shared/form.{type Form, SignUpData}
import shared/user.{type User, UserForm}

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.component(init, update, view, [])
  lustre.register(component, "visitor-page")
}

pub fn element() -> Element(msg) {
  element.element("visitor-page", [], [])
}

type Model {
  VisitorData(Form)
  Visitor(search: String)
}

pub type Msg {
  ServerCreatedAccount(Result(Response(String), rsvp.Error))
  UserTypedFullName(String)
  UserTypedEmail(String)
  UserTypedPassword(String)
  VisitorCreatedAccount
}

fn init(_args) -> #(Model, Effect(Msg)) {
  #(Visitor(""), effect.none())
}

// TODO: use gleam form
// TODO: css does not work input function does not work
// TODO: Test error handling
fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ServerCreatedAccount(Ok(_)) -> #(model, effect.none())
    ServerCreatedAccount(Error(_)) -> #(model, effect.none())
    UserTypedFullName(text) -> {
      let assert VisitorData(signup_data) = model
      case string.length(text) < 50 {
        True -> #(
          VisitorData(
            SignUpData(..signup_data, full_name: text, name_error: ""),
          ),
          effect.none(),
        )
        False -> #(
          VisitorData(
            SignUpData(
              ..signup_data,
              full_name: text,
              name_error: "Full name must be less than 50",
            ),
          ),
          effect.none(),
        )
      }
    }
    UserTypedPassword(text) -> {
      let assert VisitorData(signup_data) = model
      case is_valid_password(text) {
        True -> #(
          VisitorData(
            SignUpData(..signup_data, password: text, password_error: ""),
          ),
          effect.none(),
        )
        False -> #(
          VisitorData(
            SignUpData(
              ..signup_data,
              password: text,
              password_error: "Passord must be 6 characters long and contain a symbol",
            ),
          ),
          effect.none(),
        )
      }
    }
    UserTypedEmail(text) -> {
      let assert VisitorData(signup_data) = model
      case is_valid_email(text) {
        True -> #(
          VisitorData(SignUpData(..signup_data, email: text, email_error: "")),
          effect.none(),
        )
        False -> #(
          VisitorData(
            SignUpData(
              ..signup_data,
              email: text,
              email_error: "Email should contain a @ and a full domain name",
            ),
          ),
          effect.none(),
        )
      }
    }
    VisitorCreatedAccount -> {
      case model {
        VisitorData(SignUpData(
          full_name:,
          email:,
          password:,
          name_error: "",
          email_error: "",
          password_error: "",
        )) -> #(model, create_user(UserForm(full_name:, email:, password:)))
        _ -> #(model, effect.none())
      }
    }
  }
}

fn is_valid_password(password: String) -> Bool {
  let has_length = string.length(password) >= 6
  let assert Ok(symbol_re) = regexp.from_string("[^a-zA-Z0-9]")
  let has_symbol = regexp.check(symbol_re, password)
  has_length && has_symbol
}

fn is_valid_email(email: String) -> Bool {
  let assert Ok(email_re) = regexp.from_string("^[^@]+@[^@]+\\.[^@]+$")
  regexp.check(email_re, email)
}

fn create_user(user: User) -> Effect(Msg) {
  let body = user.user_form_to_json(user)
  let url = "/api/signup"
  rsvp.post(url, body, rsvp.expect_ok_response(ServerCreatedAccount))
}

fn view(model: Model) -> Element(Msg) {
  let styles = [
    #("max-width", "100%"),
    #("margin", "auto 16px"),
    #("display", "flex"),
    #("flex-direction", "column"),
    #("align-items", "center"),
    #("gap", "32px"),
  ]

  html.div([attribute.styles(styles)], [
    header_view(model),
    case model {
      Visitor(_) -> search_view(model)
      VisitorData(_) -> signup_form_view(model)
    },
  ])
}

fn header_view(model: Model) -> Element(Msg) {
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
    html.h2([], [html.text("Teacher Coop")]),
    header_button(model),
  ])
}

fn header_button(_model: Model) -> Element(Msg) {
  let styles = [
    #("background", "var(--color-surface)"),
    #("display", "flex"),
    #("flex-direction", "row"),
    #("gap", "20px"),
  ]
  html.div([attribute.styles(styles)], [
    html.a([], [html.text("Signup")]),
    html.a([], [html.text("Login")]),
  ])
}

fn search_view(_model: Model) {
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
      attribute.placeholder("Search..."),
    ]),
  ])
}

fn signup_form_view(model: Model) -> Element(Msg) {
  let styles = [
    #("margin", "0 auto"),
    #("display", "flex"),
    #("flex-direction", "column"),
    #("align-items", "center"),
    #("gap", "16px"),
  ]

  html.div([attribute.styles(styles)], [
    html.h1([], [
      html.text("Signup"),
    ]),
    signup_form_view(model),
    html.div([], [
      html.button([event.on_click(VisitorCreatedAccount)], [
        html.text("Create Account"),
      ]),
    ]),
  ])
}

fn signup_inputs_view(model: Model) -> Element(Msg) {
  let assert VisitorData(form) = model
  let styles = [
    #("display", "flex"),
    #("flex-direction", "column"),
    #("gap", "8px"),
  ]
  html.div([attribute.styles(styles)], [
    input(form, "text", "full-name", "Full Name"),
    input(form, "password", "password", "Password"),
    input(form, "password", "password-confirm", "Confirmation"),
    input(form, "email", "email", "Email"),
  ])
}

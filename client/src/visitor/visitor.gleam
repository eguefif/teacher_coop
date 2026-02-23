import gleam/http/response.{type Response}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp
import shared/user.{type User, UserForm}

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.component(init, update, view, [])
  lustre.register(component, "visitor-page")
}

pub fn element() -> Element(msg) {
  element.element("visitor-page", [], [])
}

type Model {
  VisitorData(full_name: String, email: String, password: String)
}

type UserInput {
  UserInput(
    full_name: String,
    email: String,
    password: String,
    full_name_error: Bool,
    email_error: Bool,
    password_error: Bool,
  )
}

pub type Msg {
  ServerCreatedAccount(Result(Response(String), rsvp.Error))
  UserTypedFullName(String)
  UserTypedEmail(String)
  UserTypedPassword(String)
  VisitorCreatedAccount
}

fn init(_args) -> #(Model, Effect(Msg)) {
  #(VisitorData("", "", ""), effect.none())
}

// TODO: Handle form error in frontend
// TODO: Handle server return
fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ServerCreatedAccount(Ok(_)) -> #(model, effect.none())
    ServerCreatedAccount(Error(_)) -> #(model, effect.none())
    UserTypedFullName(text) -> #(
      VisitorData(..model, full_name: text),
      effect.none(),
    )
    UserTypedPassword(text) -> #(
      VisitorData(..model, password: text),
      effect.none(),
    )
    UserTypedEmail(text) -> #(VisitorData(..model, email: text), effect.none())
    VisitorCreatedAccount -> {
      case model {
        VisitorData(full_name, email, password) -> #(
          model,
          create_user(UserForm(full_name:, email:, password:)),
        )
      }
    }
  }
}

fn create_user(user: User) -> Effect(Msg) {
  let body = user.user_form_to_json(user)
  let url = "/api/signup"
  rsvp.post(url, body, rsvp.expect_ok_response(ServerCreatedAccount))
}

fn view(model: Model) -> Element(Msg) {
  let styles = [
    #("max-width", "30ch"),
    #("margin", "0 auto"),
    #("display", "flex"),
    #("flex-direction", "column"),
    #("gap", "1em"),
  ]

  html.div([attribute.styles(styles)], [
    html.h1([], [
      html.text("Signup"),
      signup_form_view(model),
      html.div([], [
        html.button([event.on_click(VisitorCreatedAccount)], [
          html.text("Create Account"),
        ]),
      ]),
    ]),
  ])
}

fn signup_form_view(model: Model) -> Element(Msg) {
  let VisitorData(full_name, email, password) = model
  html.div([], [
    html.input([
      attribute.placeholder("Full name"),
      attribute.value(full_name),
      event.on_input(UserTypedFullName),
    ]),
    html.input([
      attribute.placeholder("Password"),
      attribute.value(password),
      event.on_input(UserTypedPassword),
    ]),
    html.input([
      attribute.placeholder("email"),
      attribute.value(email),
      event.on_input(UserTypedEmail),
    ]),
  ])
}

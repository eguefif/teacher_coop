import gleam/http/response.{type Response}
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
}

pub type Msg {
  ServerCreatedAccount(Result(Response(String), rsvp.Error))
  UserTypedFullName(String)
  UserTypedEmail(String)
  UserTypedPassword(String)
  VisitorCreatedAccount
}

fn init(_args) -> #(Model, Effect(Msg)) {
  #(VisitorData(SignUpData("", "", "", "", "", "")), effect.none())
}

// TODO: Handle form error in frontend
// TODO: Handle server return
fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ServerCreatedAccount(Ok(_)) -> #(model, effect.none())
    ServerCreatedAccount(Error(_)) -> #(model, effect.none())
    UserTypedFullName(text) -> {
      let VisitorData(signup_data) = model
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
      let VisitorData(signup_data) = model
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
      let VisitorData(signup_data) = model
      case is_valid_password(text) {
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

fn is_valid_password(_password) -> Bool {
  True
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
  let VisitorData(form) = model
  html.div([], [
    input(form, "text", "full-name", "Full Name"),
    input(form, "password", "password", "Password"),
    input(form, "password", "password-confirm", "Password Confirmation"),
    input(form, "email", "email", "Email"),
  ])
}

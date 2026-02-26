import formal/form.{type Form}
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
import shared/user.{type User}

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.component(init, update, view, [])
  lustre.register(component, "visitor-page")
}

pub fn element() -> Element(msg) {
  element.element("visitor-page", [], [])
}

type Model {
  VisitorSignup(Form(SignupForm))
  VisitorLogin(Form(LoginForm))
  Visitor(search: String)
  User(String)
}

type SignupForm {
  SignupForm(fullname: String, password: String, email: String)
}

type LoginForm {
  LoginForm(email: String, password: String)
}

// TODO: normalize use of Visitor and User
// We should only used User all the time but make the difference between
// logged in user and visitor user
pub type Msg {
  ServerCreatedAccount(Result(Response(String), rsvp.Error))
  UserClickedOnSignup
  UserClickedOnLogin
  UserClickedOnHome
  VisitorCreatedAccount
}

fn init(_args) -> #(Model, Effect(Msg)) {
  #(Visitor(""), effect.none())
}

// UPDATE -------------------------------------------------------------------------------------
fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserClickedOnHome -> #(Visitor(""), effect.none())
    UserClickedOnLogin -> #(VisitorLogin(new_login_form()), effect.none())
    UserClickedOnSignup -> #(VisitorSignup(new_signup_form()), effect.none())
    ServerCreatedAccount(Ok(_)) -> #(model, effect.none())
    ServerCreatedAccount(Error(_)) -> #(model, effect.none())
    VisitorCreatedAccount -> #(model, effect.none())
  }
}

fn new_login_form() -> Form(LoginForm) {
  let check_password = fn(password) {
    case string.length(password) >= 3 {
      True -> Ok(password)
      False -> Error("Password's length must be greater than 3")
    }
  }
  form.new({
    use email <- form.field("email", { form.parse_email })
    use password <- form.field("password", {
      form.parse_string |> form.check(check_password)
    })
    form.success(LoginForm(email:, password:))
  })
}

fn new_signup_form() -> Form(SignupForm) {
  let check_password = fn(password) {
    case string.length(password) >= 3 {
      True -> Ok(password)
      False -> Error("Password's length must be greater than 3")
    }
    // TODO: Add regexp to check password, must have at least one non alphabetic
  }
  form.new({
    use fullname <- form.field("fullname", { form.parse_string })
    use email <- form.field("email", { form.parse_email })
    use password <- form.field("password", {
      form.parse_string |> form.check(check_password)
    })
    form.success(SignupForm(fullname:, email:, password:))
  })
}

fn create_user(user: User) -> Effect(Msg) {
  let body = user.user_form_to_json(user)
  let url = "/api/signup"
  rsvp.post(url, body, rsvp.expect_ok_response(ServerCreatedAccount))
}

// VIEW ---------------------------------------------------------------------------------------

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
      VisitorSignup(signup_form) -> signup_form_view(signup_form)
      VisitorLogin(login_form) -> login_form_view(login_form)
      User(user) ->
        html.div([attribute.style("margin", "auto")], [
          html.text("Welcome" <> user),
        ])
    },
  ])
}

fn login_form_view(login_form: Form(LoginForm)) -> Element(Msg) {
  html.div([], [
    html.h1([], [html.text("Login")]),
    input(login_form, "email", "login_email", "Login"),
    input(login_form, "password", "login_password", "Password"),
    html.a([], [html.text("Login")]),
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
    html.h2([], [
      html.a([event.on_click(UserClickedOnHome)], [
        html.text("Teacher Coop"),
      ]),
    ]),
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
    html.a([event.on_click(UserClickedOnHome)], [html.text("Search")]),
    html.a([event.on_click(UserClickedOnSignup)], [html.text("Signup")]),
    html.a([event.on_click(UserClickedOnLogin)], [html.text("Login")]),
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

fn signup_form_view(signup_form: Form(SignupForm)) -> Element(Msg) {
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
    signup_inputs_view(signup_form),
    html.div([], [
      html.button([event.on_click(VisitorCreatedAccount)], [
        html.text("Create Account"),
      ]),
    ]),
  ])
}

fn signup_inputs_view(signup_form: Form(SignupForm)) -> Element(Msg) {
  let styles = [
    #("display", "flex"),
    #("flex-direction", "column"),
    #("gap", "8px"),
  ]
  html.div([attribute.styles(styles)], [
    input(signup_form, "text", "fullname", "Full Name"),
    input(signup_form, "password", "password", "Password"),
    input(signup_form, "password", "confirm", "Confirmation"),
    input(signup_form, "email", "email", "Email"),
  ])
}

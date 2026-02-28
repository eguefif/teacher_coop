import formal/form.{type Form}
import forms/signup_form
import g18n
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import reusables/input.{input}
import shared/translations.{fr_translator}

// TODO: finish create account logic
// - [ ] Localisation
// - [ ] Do validation on_input
// - [ ] Do validation on_submit
// - [ ] Change the submit logic from button to form
// - [ ] Use http call to create user
// - [ ] Effect on page browser route push
// - [ ] Authentication with backend and cookie session
pub fn main() -> Nil {
  let app = lustre.application(init, update, view)

  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// Model ---------------------------------------------------------------------------------------
type Model {
  Visitor(
    signup_form: Form(signup_form.SignupForm),
    login_form: Form(LoginForm),
    search: String,
    route: Route,
    translator: g18n.Translator,
  )
}

type LoginForm {
  LoginForm(email: String, password: String)
}

type Route {
  Signup
  Login
  Search
}

type Msg {
  VisitorClickedOnSignup
  VisitorEditSignupForm(signup_form.Msg)
  VisitorSubmitedSignupForm
  VisitorClickedOnHome
  VisitorClickedOnLogin
}

fn init(_) -> #(Model, Effect(Msg)) {
  let signup_form = signup_form.init()
  #(
    Visitor(
      signup_form:,
      search: "",
      login_form: new_login_form(),
      route: Search,
      translator: fr_translator(),
    ),
    effect.none(),
  )
}

fn new_login_form() -> Form(LoginForm) {
  form.new({
    use email <- form.field("email", { form.parse_email })
    use password <- form.field("password", { form.parse_string })

    form.success(LoginForm(email:, password:))
  })
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    VisitorClickedOnSignup -> update_route(model, Signup)
    VisitorSubmitedSignupForm ->
      signup_form.signup_update(
        model,
        signup_form.VisitorCreatedAccount(model.signup_form),
      )
    VisitorEditSignupForm(signup_msg) ->
      signup_form.signup_update(model, signup_msg)
    VisitorClickedOnHome -> update_route(model, Search)
    VisitorClickedOnLogin -> update_route(model, Login)
  }
}

fn update_route(model: Model, route: Route) -> #(Model, Effect(Msg)) {
  #(Visitor(..model, route:), effect.none())
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
    case model.route {
      Search -> search_view(model)
      Signup ->
        signup_form.signup_view(
          model.signup_form,
          model.translator,
          fn(signup_msg) { VisitorEditSignupForm(signup_msg) },
          VisitorSubmitedSignupForm,
        )
      Login -> login_form_view(model)
    },
  ])
}

fn login_form_view(model: Model) -> Element(Msg) {
  html.div([], [
    html.h1([], [html.text(g18n.translate(model.translator, "login.title"))]),
    // TODO: Add event in input
    //input(model.login_form, "email", "login_email", "Login"),
    //input(model.login_form, "password", "login_password", "Password"),
    html.a([], [html.text(g18n.translate(model.translator, "login.submit"))]),
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
      html.a([event.on_click(VisitorClickedOnHome)], [
        html.text(g18n.translate(model.translator, "nav.brand")),
      ]),
    ]),
    header_button(model),
  ])
}

fn header_button(model: Model) -> Element(Msg) {
  let styles = [
    #("background", "var(--color-surface)"),
    #("display", "flex"),
    #("flex-direction", "row"),
    #("gap", "20px"),
  ]
  html.div([attribute.styles(styles)], [
    html.a([event.on_click(VisitorClickedOnHome)], [
      html.text(g18n.translate(model.translator, "nav.search")),
    ]),
    html.a([event.on_click(VisitorClickedOnSignup)], [
      html.text(g18n.translate(model.translator, "nav.signup")),
    ]),
    html.a([event.on_click(VisitorClickedOnLogin)], [
      html.text(g18n.translate(model.translator, "nav.login")),
    ]),
  ])
}

fn search_view(model: Model) {
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
      attribute.placeholder(
        g18n.translate(model.translator, "search.placeholder") <> "...",
      ),
    ]),
  ])
}

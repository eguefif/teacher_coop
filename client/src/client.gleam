import formal/form.{type Form}
import forms/login
import forms/signup_form
import g18n
import gleam/result
import gleam/uri.{type Uri}
import header
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem
import search
import shared/translations.{fr_translator}

// TODO: finish create account logic
// - [x] Localisation
// - [ ] Do validation on_input
// - [ ] Do validation on_submit
// - [ ] Change the submit logic from button to form
// - [ ] Use http call to create user
// - [x] Effect on page browser route push
// - [ ] Authentication with backend and cookie session
pub fn main() -> Nil {
  let app = lustre.application(init, update, view)

  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// Model ---------------------------------------------------------------------------------------

type Model {
  Visitor(
    signup_form: signup_form.SignupForm,
    login_form: Form(login.LoginForm),
    search: String,
    route: Route,
    translator: g18n.Translator,
  )
}

type Route {
  Signup
  Login
  Search
}

fn init(_) -> #(Model, Effect(Msg)) {
  let route =
    modem.initial_uri()
    |> result.map(fn(u) { uri.path_segments(u.path) })
    |> fn(path) {
      case path {
        Ok(["search"]) -> Search
        Ok(["login"]) -> Login
        Ok(["signup"]) -> Search
        _ -> Search
      }
    }
  #(
    Visitor(
      signup_form: signup_form.init(),
      search: "",
      login_form: login.init(),
      route:,
      translator: fr_translator(),
    ),
    modem.init(on_url_change),
  )
}

fn on_url_change(uri: Uri) -> Msg {
  case uri.path_segments(uri.path) {
    ["search"] -> OnRouteChange(Search)
    ["login"] -> OnRouteChange(Login)
    ["signup"] -> OnRouteChange(Signup)
    _ -> OnRouteChange(Search)
  }
}

// Update ---------------------------------------------------------------------------------------

type Msg {
  OnRouteChange(Route)
  VisitorEditSignupForm(signup_form.Msg)
  VisitorSubmitedSignupForm
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    OnRouteChange(route) -> update_route(model, route)
    VisitorSubmitedSignupForm ->
      update_signup(model, signup_form.VisitorSubmitedSignupForm)
    VisitorEditSignupForm(signup_msg) -> update_signup(model, signup_msg)
  }
}

fn update_signup(
  model: Model,
  signup_msg: signup_form.Msg,
) -> #(Model, Effect(Msg)) {
  let #(signup_form, effect) =
    signup_form.signup_update(model.translator, model.signup_form, signup_msg)
  #(Visitor(..model, signup_form:), effect)
}

fn update_route(model: Model, route: Route) -> #(Model, Effect(Msg)) {
  #(Visitor(..model, route:), effect.none())
}

// View ---------------------------------------------------------------------------------------

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
    header.view(model.translator),
    case model.route {
      Search -> search.view(model.translator)
      Signup ->
        signup_form.view(
          model.signup_form,
          model.translator,
          fn(signup_msg) { VisitorEditSignupForm(signup_msg) },
          VisitorSubmitedSignupForm,
        )
      Login -> login.view(model.translator)
    },
  ])
}

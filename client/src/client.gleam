import api/school_api
import api/user_api
import components/search_autocomplete
import g18n
import gleam/io
import gleam/option
import gleam/string
import gleam/uri.{type Uri}
import grille_pain
import grille_pain/lustre/toast
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem
import pages/admin
import pages/login
import pages/search
import pages/signup_form
import pages/workspace
import router
import sections/header
import shared/translations.{fr_translator}
import shared/user

pub fn main() -> Nil {
  let assert Ok(_) =
    search_autocomplete.register("school", school_api.search_schools)
  let assert Ok(_) = grille_pain.simple()
  let app = lustre.application(init, update, view)

  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// Model ---------------------------------------------------------------------------------------

type Model {
  Visitor(
    signup_form: signup_form.SignupForm,
    login_form: login.LoginForm,
    search: String,
    route: router.Route,
    translator: g18n.Translator,
  )
  Pending(
    translator: g18n.Translator,
    on_success: router.Route,
    on_error: router.Route,
  )
  User(
    translator: g18n.Translator,
    search: String,
    user: user.User,
    route: router.Route,
    workspace: workspace.Model,
  )
}

fn init(_) -> #(Model, Effect(Msg)) {
  let assert Ok(uri) = modem.initial_uri()
  let route = router.from_uri(uri)
  let protected = router.is_protected_route(route)
  let configure_router = modem.init(on_url_change)

  // We check if the user has a session id by fetching the user
  let passively_fetch_user =
    user_api.get(user_api.GetWhoami) |> effect.map(UserApiMsg)

  let effects = effect.batch([configure_router, passively_fetch_user])
  #(
    case route {
      router.Login ->
        Pending(
          translator: fr_translator(),
          on_success: router.Search,
          on_error: router.Login,
        )
      _ if protected ->
        Pending(
          translator: fr_translator(),
          on_success: route,
          on_error: router.Login,
        )
      _ ->
        Pending(translator: fr_translator(), on_success: route, on_error: route)
    },
    effects,
  )
}

fn visitor_init(route: router.Route) -> Model {
  Visitor(
    signup_form: signup_form.init(),
    search: "",
    login_form: login.init(),
    route:,
    translator: fr_translator(),
  )
}

fn user_init(route: router.Route, user: user.User) -> Model {
  User(
    translator: fr_translator(),
    search: "",
    route:,
    user: user,
    workspace: workspace.fileform_init(),
  )
}

fn on_url_change(uri: Uri) -> Msg {
  router.from_uri(uri) |> UserRequestedRoute
}

// Update ---------------------------------------------------------------------------------------

type Msg {
  UserRequestedRoute(router.Route)

  VisitorEditSignupForm(signup_form.Msg)

  LoginMsg(login.Msg)

  UserApiMsg(user_api.Msg)
  HeaderMsg(header.Msg)
  WorkspaceMsg(workspace.Msg)
  //AdminMsg(admin.Msg)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  io.println(string.inspect(msg))
  //io.println(string.inspect(model))
  case model, msg {
    _, UserRequestedRoute(route) -> #(update_route(model, route), effect.none())
    User(..), _ -> update_user(model, msg)
    Pending(..), _ -> update_pending(model, msg)
    Visitor(..), _ -> update_visitor(model, msg)
  }
}

fn update_user(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let assert User(..) = model
  case msg {
    HeaderMsg(header.Logout) -> #(
      visitor_init(router.Search),
      user_api.logout() |> effect.map(UserApiMsg),
    )
    UserApiMsg(user_api.ApiLogout(_)) -> #(
      update_route(model, router.Search),
      toast.success(g18n.translate(model.translator, "login.logout")),
    )
    WorkspaceMsg(msg) -> update_workspace(model, msg)
    _ -> #(model, effect.none())
  }
}

// -------- Update Route
fn update_route(model: Model, route: router.Route) -> Model {
  let protected = router.is_protected_route(route)
  let admin = router.is_admin_route(route)
  case model {
    User(..) if admin -> User(..model, route: router.Search)
    User(..) -> User(..model, route:)
    Pending(..) -> panic
    Visitor(..) if protected -> Visitor(..model, route: router.Login)
    Visitor(..) -> Visitor(..model, route:)
  }
}

// -------- Update Workspace
fn update_workspace(model: Model, msg: workspace.Msg) -> #(Model, Effect(Msg)) {
  let assert User(..) = model
  let #(workspace, effect) =
    workspace.update(model.translator, model.workspace, msg)
  #(User(..model, workspace:), effect.map(effect, WorkspaceMsg))
}

// -------- Update Pending
fn update_pending(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let assert Pending(..) = model
  let assert UserApiMsg(msg) = msg
  case msg {
    user_api.ApiReturnedUser(Ok(user)) -> {
      #(user_init(model.on_success, user), effect.none())
    }
    user_api.ApiReturnedUser(Error(_)) -> {
      #(visitor_init(model.on_error), effect.none())
    }
    _ -> panic
  }
}

// -------- Update Visitor
fn update_visitor(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  // Simplify Visitor Message: only have one wrapper and use signup.Msg in pattern matching
  let assert Visitor(..) = model
  case msg {
    // Signup FormMessage
    VisitorEditSignupForm(signup_form.ServerCreatedAccount(Ok(_))) -> {
      #(
        update_route(model, router.Search),
        toast.success(g18n.translate(model.translator, "signup.account_created")),
      )
    }
    VisitorEditSignupForm(signup_form.ServerCreatedAccount(Error(_))) -> {
      // TODO: we should not display an error here but the form
      #(
        update_route(model, router.Search),
        toast.error(g18n.translate(
          model.translator,
          "signup.error_account_created",
        )),
      )
    }
    VisitorEditSignupForm(signup_msg) -> update_signup(model, signup_msg)

    // Login Form Message
    LoginMsg(login.ServerCreatedSession(Ok(user))) -> {
      #(
        update_route(user_init(router.Search, user), router.Search),
        effect.none(),
      )
    }
    LoginMsg(msg) -> {
      update_login(model, msg)
    }
    // Other Message
    UserApiMsg(_msg) -> #(model, effect.none())
    _ -> panic
  }
}

fn update_signup(
  model: Model,
  signup_msg: signup_form.Msg,
) -> #(Model, Effect(Msg)) {
  let assert Visitor(..) = model
  let #(signup_form, effect) =
    signup_form.signup_update(model.translator, model.signup_form, signup_msg)
  #(Visitor(..model, signup_form:), effect.map(effect, VisitorEditSignupForm))
}

fn update_login(model: Model, login_msg: login.Msg) -> #(Model, Effect(Msg)) {
  let assert Visitor(..) = model
  let #(login_form, effect) = login.update(model.login_form, login_msg)
  #(Visitor(..model, login_form:), effect.map(effect, LoginMsg))
}

// View ---------------------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  case model {
    Pending(..) -> html.div([], [])
    Visitor(..) -> visitor_view(model)
    User(..) -> user_view(model)
  }
}

fn visitor_view(model: Model) -> Element(Msg) {
  let assert Visitor(..) = model
  let styles = [
    #("max-width", "100%"),
    #("margin", "auto 16px"),
    #("display", "flex"),
    #("flex-direction", "column"),
    #("align-items", "center"),
    #("gap", "32px"),
  ]

  html.div([attribute.styles(styles)], [
    header.view(model.translator, option.None, fn(msg) { HeaderMsg(msg) }),
    case model.route {
      router.Search -> search.view(model.translator)
      router.Signup -> signup_view(model)
      router.Login -> login_view(model)
      _ -> panic
    },
  ])
}

fn user_view(model: Model) -> Element(Msg) {
  let assert User(..) = model
  let styles = [
    #("max-width", "100%"),
    #("margin", "auto 16px"),
    #("display", "flex"),
    #("flex-direction", "column"),
    #("align-items", "center"),
    #("gap", "32px"),
  ]

  html.div([attribute.styles(styles)], [
    header.view(model.translator, option.Some(model.user), fn(msg) {
      HeaderMsg(msg)
    }),
    case model.route {
      router.Search | router.Login | router.Signup ->
        search.view(model.translator)
      router.Workspace ->
        workspace.view(model.translator, model.workspace, fn(msg) {
          WorkspaceMsg(msg)
        })
      router.Admin -> admin.view()
    },
  ])
}

fn signup_view(model: Model) -> Element(Msg) {
  let assert Visitor(..) = model
  signup_form.view(model.signup_form, model.translator, fn(signup_msg) {
    VisitorEditSignupForm(signup_msg)
  })
}

fn login_view(model: Model) -> Element(Msg) {
  let assert Visitor(..) = model
  login.view(model.login_form, model.translator, fn(login_msg) {
    LoginMsg(login_msg)
  })
}

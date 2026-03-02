import g18n
import gleam/option
import gleam/regexp
import gleam/string
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import reusables/button.{button}
import reusables/input.{input}
import rsvp
import shared/user.{UserLoginForm}

// Model ---------------------------------------------------------------------------------------

// TODO: Work on serverside auth
pub type LoginForm {
  LoginForm(
    email: String,
    password: String,
    error_email: String,
    error_password: String,
    valid_email: Bool,
    valid_password: Bool,
    error: Bool,
  )
}

pub type Msg {
  ServerCreatedSession(Result(user.User, rsvp.Error))
  VisitorSubmitedLoginForm
  VisitorUpdatedEmail(String)
  VisitorUpdatedPassword(String)
  VisitorFinishUpdatedPassword
  VisitorFinishUpdatedEmail
}

pub fn init() -> LoginForm {
  LoginForm("", "", "", "", False, False, False)
}

// Update ---------------------------------------------------------------------------------------

pub fn update(
  translator: g18n.Translator,
  form: LoginForm,
  msg: Msg,
) -> #(LoginForm, Effect(Msg)) {
  case msg {
    ServerCreatedSession(Error(_)) -> handle_error(form)
    ServerCreatedSession(_) -> #(form, effect.none())
    VisitorSubmitedLoginForm -> handle_login(form)
    VisitorUpdatedEmail(email) -> update_email(form, email)
    VisitorUpdatedPassword(password) -> update_password(form, password)
    VisitorFinishUpdatedEmail -> validate_email(translator, form)
    VisitorFinishUpdatedPassword -> validate_password(translator, form)
  }
}

fn handle_error(form) -> #(LoginForm, Effect(Msg)) {
  #(LoginForm(..form, error: False), effect.none())
}

fn validate_password(
  translator: g18n.Translator,
  form: LoginForm,
) -> #(LoginForm, Effect(Msg)) {
  let assert Ok(re) = regexp.from_string("[^a-zA-Z0-9]")
  case string.length(form.password) > 3 && regexp.check(re, form.password) {
    True -> #(
      LoginForm(..form, error_password: "", valid_password: True),
      effect.none(),
    )
    False -> #(
      LoginForm(
        ..form,
        error_password: g18n.translate(translator, "signup.error_password"),
        valid_password: False,
      ),
      effect.none(),
    )
  }
}

fn validate_email(
  translator: g18n.Translator,
  form: LoginForm,
) -> #(LoginForm, Effect(Msg)) {
  let assert Ok(re) = regexp.from_string("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")
  case regexp.check(re, form.email) {
    True -> #(
      LoginForm(..form, error_email: "", valid_email: True),
      effect.none(),
    )
    False -> #(
      LoginForm(
        ..form,
        error_email: g18n.translate(translator, "signup.error_email"),
        valid_email: False,
      ),
      effect.none(),
    )
  }
}

fn update_password(
  form: LoginForm,
  password: String,
) -> #(LoginForm, Effect(Msg)) {
  #(LoginForm(..form, password:), effect.none())
}

fn update_email(form: LoginForm, email: String) -> #(LoginForm, Effect(Msg)) {
  #(LoginForm(..form, email:), effect.none())
}

fn handle_login(form: LoginForm) -> #(LoginForm, Effect(Msg)) {
  let user = UserLoginForm(email: form.email, password: form.password)
  let body = user.user_login_form_to_json(user)
  let url = "/api/auth/login"
  #(
    form,
    rsvp.post(
      url,
      body,
      rsvp.expect_json(user.user_decoder(), ServerCreatedSession),
    ),
  )
}

// View ---------------------------------------------------------------------------------------

pub fn view(
  login_form: LoginForm,
  translator: g18n.Translator,
  visitor_updated_loginform_msg: fn(Msg) -> msg,
  visitor_submited_loginform_msg: msg,
) -> Element(msg) {
  html.div([], [
    html.form([], [
      html.h1([], [html.text(g18n.translate(translator, "login.title"))]),
      input(
        login_form.email,
        login_form.error_email,
        login_form.valid_email,
        fn(value) { visitor_updated_loginform_msg(VisitorUpdatedEmail(value)) },
        visitor_updated_loginform_msg(VisitorFinishUpdatedEmail),
        "email",
        "email",
        g18n.translate(translator, "login.email"),
      ),

      input(
        login_form.password,
        login_form.error_password,
        login_form.valid_password,
        fn(value) {
          visitor_updated_loginform_msg(VisitorUpdatedPassword(value))
        },
        visitor_updated_loginform_msg(VisitorFinishUpdatedPassword),
        "password",
        "password",
        g18n.translate(translator, "login.password"),
      ),
      button(
        option.Some(visitor_submited_loginform_msg),
        g18n.translate(translator, "login.submit"),
      ),
      html.p(
        [
          attribute.style("visibility", case login_form.error {
            True -> "visible"
            False -> "hidden"
          }),
        ],
        [html.text(g18n.translate(translator, "login.error"))],
      ),
    ]),
  ])
}

import g18n
import gleam/option
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import reusables/button.{button}
import reusables/input.{input}
import rsvp
import shared/user.{UserLoginForm}

// Model ---------------------------------------------------------------------------------------

pub type LoginForm {
  LoginForm(email: String, password: String, error: Bool)
}

pub type Msg {
  ServerCreatedSession(Result(user.User, rsvp.Error))
  VisitorSubmitedLoginForm(List(#(String, String)))
  VisitorUpdatedEmail(String)
  VisitorUpdatedPassword(String)
}

pub fn init() -> LoginForm {
  LoginForm("", "", False)
}

// Update ---------------------------------------------------------------------------------------

pub fn update(form: LoginForm, msg: Msg) -> #(LoginForm, Effect(Msg)) {
  case msg {
    ServerCreatedSession(Error(_)) -> handle_error(form)
    ServerCreatedSession(_) -> panic

    VisitorSubmitedLoginForm(_) -> handle_login(form)
    VisitorUpdatedEmail(email) -> update_email(form, email)
    VisitorUpdatedPassword(password) -> update_password(form, password)
  }
}

fn handle_error(form) -> #(LoginForm, Effect(Msg)) {
  #(LoginForm(..form, error: True), effect.none())
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
  wrapper_msg: fn(Msg) -> msg,
) -> Element(msg) {
  html.div([attribute.class("login-container")], [
    login_style(),
    html.h1([], [html.text(g18n.translate(translator, "login.title"))]),
    html.form(
      [
        attribute.class("login-form"),
        event.on_submit(fn(v) { wrapper_msg(VisitorSubmitedLoginForm(v)) }),
      ],
      [
        input(
          login_form.email,
          "",
          False,
          fn(value) { wrapper_msg(VisitorUpdatedEmail(value)) },
          option.None,
          "email",
          "email",
          g18n.translate(translator, "login.email"),
        ),
        input(
          login_form.password,
          "",
          False,
          fn(value) { wrapper_msg(VisitorUpdatedPassword(value)) },
          option.None,
          "password",
          "password",
          g18n.translate(translator, "login.password"),
        ),
        html.div([attribute.class("login-submit")], [
          button(
            option.None,
            g18n.translate(translator, "login.submit"),
            "submit",
          ),
        ]),
        html.p(
          [
            attribute.class(case login_form.error {
              True -> "login-error visible"
              False -> "login-error"
            }),
          ],
          [html.text(g18n.translate(translator, "login.error"))],
        ),
      ],
    ),
  ])
}

fn login_style() -> Element(msg) {
  html.style(
    [],
    "
    .login-container {
      margin: auto;
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    .login-form {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .login-submit {
      margin: 0 auto;
    }
    .login-error {
      color: var(--color-danger);
      visibility: hidden;
    }
    .login-error.visible {
      visibility: visible;
    }
    ",
  )
}

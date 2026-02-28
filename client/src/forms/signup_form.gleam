import g18n
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import reusables/button.{button}
import reusables/input.{input}
import rsvp
import shared/user.{type User, UserForm}

// Model ---------------------------------------------------------------------------------------

pub type SignupForm {
  SignupForm(
    fullname: String,
    email: String,
    password: String,
    confirmation: String,
    error_fullname: String,
    error_email: String,
    error_password: String,
    error_confirmation: String,
  )
}

pub fn init() -> SignupForm {
  SignupForm("", "", "", "", "", "", "", "")
}

// Update ---------------------------------------------------------------------------------------

pub type Msg {
  VisitorSubmitedSignupForm

  VisitorUpdateFullname(String)
  VisitorUpdateEmail(String)
  VisitorUpdatePassword(String)
  VisitorUpdateConfirmation(String)
}

pub fn signup_update(
  translator: g18n.Translator,
  signup_form: SignupForm,
  msg: Msg,
) -> #(SignupForm, Effect(msg)) {
  case msg {
    VisitorSubmitedSignupForm -> #(signup_form, handle_create_user(signup_form))

    // Input Validation on_input
    VisitorUpdateFullname(fullname) ->
      validate_fullname(translator, signup_form, fullname)
    VisitorUpdateEmail(email) -> validate_email(translator, signup_form, email)
    VisitorUpdatePassword(password) ->
      validate_password(translator, signup_form, password)
    VisitorUpdateConfirmation(confirmation) ->
      validate_confirmation(translator, signup_form, confirmation)
  }
}

fn validate_fullname(
  translator: g18n.Translator,
  signup_form: SignupForm,
  fullname: String,
) -> #(SignupForm, Effect(msg)) {
  case string.length(fullname) > 3 {
    True -> #(
      SignupForm(..signup_form, fullname:, error_fullname: ""),
      effect.none(),
    )
    False -> #(
      SignupForm(
        ..signup_form,
        fullname: fullname,
        error_fullname: g18n.translate(translator, "signup.error_fullname"),
      ),
      effect.none(),
    )
  }
}

fn validate_email(
  translator: g18n.Translator,
  signup_form: SignupForm,
  email: String,
) -> #(SignupForm, Effect(msg)) {
  let assert Ok(re) = regexp.from_string("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")
  case regexp.check(re, email) {
    True -> #(SignupForm(..signup_form, email:, error_email: ""), effect.none())
    False -> #(
      SignupForm(
        ..signup_form,
        email:,
        error_email: g18n.translate(translator, "signup.error_email"),
      ),
      effect.none(),
    )
  }
}

fn validate_password(
  translator: g18n.Translator,
  signup_form: SignupForm,
  password: String,
) -> #(SignupForm, Effect(msg)) {
  let assert Ok(re) = regexp.from_string("[^a-zA-Z0-9]")
  case string.length(password) > 3 && regexp.check(re, password) {
    True -> #(
      SignupForm(..signup_form, password:, error_password: ""),
      effect.none(),
    )
    False -> #(
      SignupForm(
        ..signup_form,
        password:,
        error_password: g18n.translate(translator, "signup.error_password"),
      ),
      effect.none(),
    )
  }
}

fn validate_confirmation(
  translator: g18n.Translator,
  signup_form: SignupForm,
  confirmation: String,
) -> #(SignupForm, Effect(msg)) {
  case confirmation == signup_form.password {
    True -> #(
      SignupForm(..signup_form, confirmation:, error_confirmation: ""),
      effect.none(),
    )
    False -> #(
      SignupForm(
        ..signup_form,
        confirmation:,
        error_confirmation: g18n.translate(
          translator,
          "signup.error_confirmation",
        ),
      ),
      effect.none(),
    )
  }
}

fn handle_create_user(form: SignupForm) -> Effect(msg) {
  // Run the form validation and handle return in case
  create_user(UserForm(
    full_name: form.fullname,
    email: form.email,
    password: form.password,
  ))
}

fn create_user(user: User) -> Effect(msg) {
  let _body = user.user_form_to_json(user)
  let url = "/api/signup"
  io.println(url <> ": Creating user")
  effect.none()
  // rsvp.post(url, body, rsvp.expect_ok_response(ServerCreatedAccount))
}

// VIEW ---------------------------------------------------------------------------------------

pub fn view(
  signup_form: SignupForm,
  translator: g18n.Translator,
  visitor_edit_signup_form: fn(Msg) -> msg,
  visitor_submited_signup_form: msg,
) -> Element(msg) {
  let styles = [
    #("margin", "0 auto"),
    #("display", "flex"),
    #("flex-direction", "column"),
    #("align-items", "center"),
    #("gap", "16px"),
  ]

  let inputs_div_styles = [
    #("display", "flex"),
    #("flex-direction", "column"),
    #("gap", "8px"),
  ]

  html.div([attribute.styles(styles)], [
    html.h1([], [
      html.text(g18n.translate(translator, "signup.title")),
    ]),
    html.div([attribute.styles(inputs_div_styles)], [
      input(
        signup_form.fullname,
        signup_form.error_fullname,
        fn(s) { visitor_edit_signup_form(VisitorUpdateFullname(s)) },
        "text",
        "fullname",
        g18n.translate(translator, "signup.fullname"),
      ),
      input(
        signup_form.password,
        signup_form.error_password,
        fn(s) { visitor_edit_signup_form(VisitorUpdatePassword(s)) },
        "password",
        "password",
        g18n.translate(translator, "signup.password"),
      ),
      input(
        signup_form.confirmation,
        signup_form.error_confirmation,
        fn(s) { visitor_edit_signup_form(VisitorUpdateConfirmation(s)) },
        "password",
        "confirm",
        g18n.translate(translator, "signup.confirm"),
      ),
      input(
        signup_form.email,
        signup_form.error_email,
        fn(s) { visitor_edit_signup_form(VisitorUpdateEmail(s)) },
        "email",
        "email",
        g18n.translate(translator, "signup.email"),
      ),
    ]),
    button(
      visitor_submited_signup_form,
      g18n.translate(translator, "signup.submit"),
    ),
  ])
}

import formal/form.{type Form}
import g18n
import gleam/http/response.{type Response}
import gleam/io
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import reusables/button.{button}
import reusables/input.{input}
import rsvp
import shared/user.{type User, UserForm}

pub type SignupForm {
  SignupForm(fullname: String, email: String, password: String)
}

pub type Msg {
  VisitorCreatedAccount(Form(SignupForm))
  VisitorUpdateFullname(String)
  VisitorUpdateEmail(String)
  VisitorUpdatePassword(String)
  VisitorUpdateConfirmation(String)
}

pub fn signup_update(model: model, msg: Msg) -> #(model, Effect(msg)) {
  case msg {
    VisitorCreatedAccount(form) -> #(model, handle_create_user(form))
    VisitorUpdateFullname(fullname) -> validate_fullname(model, fullname)
    VisitorUpdateEmail(email) -> validate_email(model, email)
    VisitorUpdatePassword(password) -> validate_password(model, password)
    VisitorUpdateConfirmation(confirmation) ->
      validate_confirmation(model, confirmation)
  }
}

fn validate_confirmation(
  model: model,
  confirmation: String,
) -> #(model, Effect(msg)) {
  todo
}

fn validate_password(model: model, password: String) -> #(model, Effect(msg)) {
  todo
}

fn validate_email(model: model, email: String) -> #(model, Effect(msg)) {
  todo
}

fn validate_fullname(model: model, fullname: String) -> #(model, Effect(msg)) {
  todo
}

pub fn init() -> Form(SignupForm) {
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

fn handle_create_user(_form: Form(SignupForm)) -> Effect(msg) {
  // Run the form validation and handle return in case
  create_user(UserForm(
    full_name: "Emmanuel",
    email: "eguefif@gmail.com",
    password: "password",
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

pub fn signup_view(
  signup_form: Form(SignupForm),
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
        signup_form,
        fn(s) { visitor_edit_signup_form(VisitorUpdateFullname(s)) },
        "text",
        "fullname",
        g18n.translate(translator, "signup.fullname"),
      ),
      input(
        signup_form,
        fn(s) { visitor_edit_signup_form(VisitorUpdatePassword(s)) },
        "password",
        "password",
        g18n.translate(translator, "signup.password"),
      ),
      input(
        signup_form,
        fn(s) { visitor_edit_signup_form(VisitorUpdateConfirmation(s)) },
        "password",
        "confirm",
        g18n.translate(translator, "signup.confirm"),
      ),
      input(
        signup_form,
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

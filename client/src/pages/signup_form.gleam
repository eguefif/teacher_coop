import components/search_autocomplete
import g18n
import gleam/http/response
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import reusables/button.{button}
import reusables/input.{input}
import rsvp
import shared/user.{
  type User, DuplicateEmail, UserForm, UserFormError, user_form_error_from_json,
}

// TODO:: need to have responsivness, error text is not well display when reduced window

// Model ---------------------------------------------------------------------------------------

pub type SignupForm {
  SignupForm(
    fullname: String,
    email: String,
    password: String,
    confirmation: String,
    school_id: String,
    error_fullname: String,
    error_email: String,
    error_password: String,
    error_confirmation: String,
    valid_fullname: Bool,
    valid_email: Bool,
    valid_password: Bool,
    valid_confirmation: Bool,
  )
}

pub fn init() -> SignupForm {
  SignupForm("", "", "", "", "", "", "", "", "", False, False, False, False)
}

// Update ---------------------------------------------------------------------------------------

pub type Msg {
  ServerCreatedAccount(Result(response.Response(String), rsvp.Error))
  VisitorSubmitedSignupForm(List(#(String, String)))

  VisitorUpdateFullname(String)
  VisitorUpdateEmail(String)
  VisitorUpdatePassword(String)
  VisitorUpdateConfirmation(String)
  VisitorFinishUpdatedFullname
  VisitorFinishUpdatedEmail
  VisitorFinishUpdatedPassword
  VisitorFinishUpdatedConfirmation
  VisitorClickedOnSchool(String)
}

pub fn signup_update(
  translator: g18n.Translator,
  signup_form: SignupForm,
  msg: Msg,
) -> #(SignupForm, Effect(Msg)) {
  case msg {
    VisitorSubmitedSignupForm(_) -> handle_create_user(signup_form)

    // Input Validation on_input
    VisitorUpdateFullname(fullname) -> update_fullname(signup_form, fullname)
    VisitorUpdateEmail(email) -> update_email(signup_form, email)
    VisitorUpdatePassword(password) -> update_password(signup_form, password)
    VisitorUpdateConfirmation(confirmation) ->
      update_confirmation(signup_form, confirmation)
    VisitorFinishUpdatedFullname -> validate_fullname(translator, signup_form)
    VisitorFinishUpdatedEmail -> validate_email(translator, signup_form)
    VisitorFinishUpdatedPassword -> validate_password(translator, signup_form)
    VisitorFinishUpdatedConfirmation ->
      validate_confirmation(translator, signup_form)

    VisitorClickedOnSchool(school_id) -> #(
      SignupForm(..signup_form, school_id:),
      effect.none(),
    )

    ServerCreatedAccount(Error(rsvp.HttpError(response.Response(400, _, body)))) ->
      handle_api_error(translator, signup_form, body)
    ServerCreatedAccount(_) -> #(signup_form, effect.none())
  }
}

fn handle_api_error(
  translator: g18n.Translator,
  model: SignupForm,
  body: String,
) -> #(SignupForm, Effect(Msg)) {
  let model = case user_form_error_from_json(body) {
    Ok(UserFormError(errors)) ->
      list.fold(errors, model, fn(model, error) {
        case error {
          DuplicateEmail ->
            SignupForm(
              ..model,
              error_email: g18n.translate(
                translator,
                "signup.error_email_duplicate",
              ),
              valid_email: False,
            )
        }
      })
    _ -> {
      io.println("Error: Decode error")
      model
    }
  }

  #(model, effect.none())
}

fn update_email(
  signup_form: SignupForm,
  email: String,
) -> #(SignupForm, Effect(Msg)) {
  #(
    SignupForm(..signup_form, email:, valid_email: False, error_email: ""),
    effect.none(),
  )
}

fn update_confirmation(
  signup_form: SignupForm,
  confirmation: String,
) -> #(SignupForm, Effect(Msg)) {
  #(
    SignupForm(..signup_form, confirmation:, error_confirmation: ""),
    effect.none(),
  )
}

fn update_password(
  signup_form: SignupForm,
  password: String,
) -> #(SignupForm, Effect(Msg)) {
  #(SignupForm(..signup_form, password:, error_password: ""), effect.none())
}

fn update_fullname(
  signup_form: SignupForm,
  fullname: String,
) -> #(SignupForm, Effect(Msg)) {
  #(SignupForm(..signup_form, fullname:, error_fullname: ""), effect.none())
}

fn validate_fullname(
  translator: g18n.Translator,
  signup_form: SignupForm,
) -> #(SignupForm, Effect(Msg)) {
  case string.length(signup_form.fullname) > 3 {
    True -> #(
      SignupForm(..signup_form, error_fullname: "", valid_fullname: True),
      effect.none(),
    )
    False -> #(
      SignupForm(
        ..signup_form,
        error_fullname: g18n.translate(translator, "signup.error_fullname"),
        valid_fullname: False,
      ),
      effect.none(),
    )
  }
}

fn validate_email(
  translator: g18n.Translator,
  signup_form: SignupForm,
) -> #(SignupForm, Effect(Msg)) {
  let assert Ok(re) = regexp.from_string("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")
  case regexp.check(re, signup_form.email) {
    True -> #(
      SignupForm(..signup_form, error_email: "", valid_email: True),
      effect.none(),
    )
    False -> #(
      SignupForm(
        ..signup_form,
        error_email: g18n.translate(translator, "signup.error_email"),
        valid_email: False,
      ),
      effect.none(),
    )
  }
}

fn validate_password(
  translator: g18n.Translator,
  signup_form: SignupForm,
) -> #(SignupForm, Effect(Msg)) {
  let assert Ok(re) = regexp.from_string("[^a-zA-Z0-9]")
  case
    string.length(signup_form.password) > 3
    && regexp.check(re, signup_form.password)
  {
    True -> #(
      SignupForm(..signup_form, error_password: "", valid_password: True),
      effect.none(),
    )
    False -> #(
      SignupForm(
        ..signup_form,
        error_password: g18n.translate(translator, "signup.error_password"),
        valid_password: False,
      ),
      effect.none(),
    )
  }
}

fn validate_confirmation(
  translator: g18n.Translator,
  signup_form: SignupForm,
) -> #(SignupForm, Effect(Msg)) {
  case signup_form.confirmation == signup_form.password {
    True -> #(
      SignupForm(
        ..signup_form,
        error_confirmation: "",
        valid_confirmation: True,
      ),
      effect.none(),
    )
    False -> #(
      SignupForm(
        ..signup_form,
        error_confirmation: g18n.translate(
          translator,
          "signup.error_confirmation",
        ),
        valid_confirmation: False,
      ),
      effect.none(),
    )
  }
}

fn handle_create_user(form: SignupForm) -> #(SignupForm, Effect(Msg)) {
  // Run the form validation and handle return in case
  case
    form.valid_fullname
    && form.valid_email
    && form.valid_password
    && form.valid_confirmation
  {
    True -> #(
      form,
      create_user(UserForm(
        full_name: form.fullname,
        email: form.email,
        password: form.password,
        school_id: form.school_id,
      )),
    )
    False -> #(form, effect.none())
  }
}

// TODO: Refactor project API handling: think of where to put everything api related
fn create_user(user: User) -> Effect(Msg) {
  let body = user.user_form_to_json(user)
  let url = "/api/signup"
  rsvp.post(url, body, rsvp.expect_ok_response(ServerCreatedAccount))
}

// VIEW ---------------------------------------------------------------------------------------

pub fn view(
  signup_form: SignupForm,
  translator: g18n.Translator,
  wrapper_msg: fn(Msg) -> msg,
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
    html.form(
      [
        event.on_submit(fn(form) {
          wrapper_msg(VisitorSubmitedSignupForm(form))
        }),
      ],
      [
        html.div([attribute.styles(inputs_div_styles)], [
          input(
            signup_form.fullname,
            signup_form.error_fullname,
            signup_form.valid_fullname,
            fn(s) { wrapper_msg(VisitorUpdateFullname(s)) },
            option.Some(wrapper_msg(VisitorFinishUpdatedFullname)),
            "text",
            "fullname",
            g18n.translate(translator, "signup.fullname"),
          ),
          input(
            signup_form.password,
            signup_form.error_password,
            signup_form.valid_password,
            fn(s) { wrapper_msg(VisitorUpdatePassword(s)) },
            option.Some(wrapper_msg(VisitorFinishUpdatedPassword)),
            "password",
            "password",
            g18n.translate(translator, "signup.password"),
          ),
          input(
            signup_form.confirmation,
            signup_form.error_confirmation,
            signup_form.valid_confirmation,
            fn(s) { wrapper_msg(VisitorUpdateConfirmation(s)) },
            option.Some(wrapper_msg(VisitorFinishUpdatedConfirmation)),
            "password",
            "confirm",
            g18n.translate(translator, "signup.confirm"),
          ),
          input(
            signup_form.email,
            signup_form.error_email,
            signup_form.valid_email,
            fn(s) { wrapper_msg(VisitorUpdateEmail(s)) },
            option.Some(wrapper_msg(VisitorFinishUpdatedEmail)),
            "email",
            "email",
            g18n.translate(translator, "signup.email"),
          ),
          search_autocomplete.element("school", [
            search_autocomplete.on_click(fn(s) {
              wrapper_msg(VisitorClickedOnSchool(s))
            }),
            search_autocomplete.attribute_input_label(g18n.translate(
              translator,
              "signup.school",
            )),
          ]),
          html.div([attribute.style("margin", "0 auto 0 auto")], [
            button(
              option.None,
              g18n.translate(translator, "signup.submit"),
              "submit",
            ),
          ]),
        ]),
      ],
    ),
  ])
}

import formal/form.{type Form}
import g18n
import lustre/element.{type Element}
import lustre/element/html

pub type LoginForm {
  LoginForm(email: String, password: String)
}

pub fn init() -> Form(LoginForm) {
  form.new({
    use email <- form.field("email", { form.parse_email })
    use password <- form.field("password", { form.parse_string })

    form.success(LoginForm(email:, password:))
  })
}

pub fn view(translator: g18n.Translator) -> Element(msg) {
  html.div([], [
    html.h1([], [html.text(g18n.translate(translator, "login.title"))]),
    // TODO: Add event in input
    //input(model.login_form, "email", "login_email", "Login"),
    //input(model.login_form, "password", "login_password", "Password"),
    html.a([], [html.text(g18n.translate(translator, "login.submit"))]),
  ])
}

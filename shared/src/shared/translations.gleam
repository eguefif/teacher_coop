import g18n
import g18n/locale

pub fn fr_translations() -> g18n.Translations {
  g18n.new_translations()
  |> g18n.add_translation("login.email", "Identifiant")
  |> g18n.add_translation("login.password", "Mot de passe")
  |> g18n.add_translation("login.submit", "Se connecter")
  |> g18n.add_translation("login.title", "Connexion")
  |> g18n.add_translation("nav.brand", "Teacher Coop")
  |> g18n.add_translation("nav.login", "Se connecter")
  |> g18n.add_translation("nav.search", "Rechercher")
  |> g18n.add_translation("nav.signup", "S'inscrire")
  |> g18n.add_translation("search.placeholder", "Rechercher...")
  |> g18n.add_translation("signup.confirm", "Confirmation")
  |> g18n.add_translation("signup.email", "Email")
  |> g18n.add_translation(
    "signup.error_confirmation",
    "Les mots de passe ne correspondent pas.",
  )
  |> g18n.add_translation(
    "signup.error_email",
    "Votre adresse couriel est invalide.",
  )
  |> g18n.add_translation(
    "signup.error_fullname",
    "Votre nom complet doit contenir au moins 3 charactères.",
  )
  |> g18n.add_translation(
    "signup.error_password",
    "Votre mot de passe doit contenir au moins 3 charactères et un chifre/symbole.",
  )
  |> g18n.add_translation("signup.fullname", "Nom complet")
  |> g18n.add_translation("signup.password", "Mot de passe")
  |> g18n.add_translation("signup.submit", "Créer")
  |> g18n.add_translation("signup.title", "Inscription")
  |> g18n.add_translation("user.welcome", "Bienvenue {name} !")
  |> g18n.add_translation(
    "validation.password.no_special_char",
    "Le mot de passe doit contenir au moins un caractère non alphabétique",
  )
  |> g18n.add_translation(
    "validation.password.too_short",
    "Le mot de passe doit contenir au moins 3 caractères",
  )
}

pub fn fr_locale() -> locale.Locale {
  let assert Ok(locale) = locale.new("fr")
  locale
}

pub fn fr_translator() -> g18n.Translator {
  g18n.new_translator(fr_locale(), fr_translations())
}

pub fn en_translations() -> g18n.Translations {
  g18n.new_translations()
  |> g18n.add_translation("login.email", "Login")
  |> g18n.add_translation("login.password", "Password")
  |> g18n.add_translation("login.submit", "Login")
  |> g18n.add_translation("login.title", "Login")
  |> g18n.add_translation("nav.brand", "Teacher Coop")
  |> g18n.add_translation("nav.login", "Login")
  |> g18n.add_translation("nav.search", "Search")
  |> g18n.add_translation("nav.signup", "Signup")
  |> g18n.add_translation("search.placeholder", "Search...")
  |> g18n.add_translation("signup.confirm", "Confirmation")
  |> g18n.add_translation("signup.email", "Email")
  |> g18n.add_translation("signup.error_confirmation", "Passwords do not match")
  |> g18n.add_translation("signup.error_email", "Your email address is invalid")
  |> g18n.add_translation(
    "signup.error_fullname",
    "Your full name must contain at least 3 characters.",
  )
  |> g18n.add_translation(
    "signup.error_password",
    "Your password must contain at least 3 characters and one digit/symbol",
  )
  |> g18n.add_translation("signup.fullname", "Full Name")
  |> g18n.add_translation("signup.password", "Password")
  |> g18n.add_translation("signup.submit", "Create")
  |> g18n.add_translation("signup.title", "Signup")
  |> g18n.add_translation("user.welcome", "Welcome {name}!")
  |> g18n.add_translation(
    "validation.password.no_special_char",
    "Password must contain at least one non-alphabetic character",
  )
  |> g18n.add_translation(
    "validation.password.too_short",
    "Password must be at least 3 characters long",
  )
}

pub fn en_locale() -> locale.Locale {
  let assert Ok(locale) = locale.new("en")
  locale
}

pub fn en_translator() -> g18n.Translator {
  g18n.new_translator(en_locale(), en_translations())
}

pub fn available_locales() -> List(String) {
  ["fr", "en"]
}

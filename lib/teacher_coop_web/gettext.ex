defmodule TeacherCoopWeb.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](https://gettext.hexdocs.pm), your module compiles translations
  that you can use in your application. To use this Gettext backend module,
  call `use Gettext` and pass it as an option:

      use Gettext, backend: TeacherCoopWeb.Gettext

      # Simple translation
      gettext("Here is the string to translate")

      # Plural translation
      ngettext("Here is the string to translate",
               "Here are the strings to translate",
               3)

      # Domain-based translation
      dgettext("errors", "Here is the error message to translate")

  See the [Gettext Docs](https://gettext.hexdocs.pm) for detailed usage.
  """

  # `use Gettext.Backend` generates a private per-locale/domain plural
  # function (dynamically named, e.g. `en_default_plural/1`) that embeds a
  # compiled `%Expo.PluralForms{}` (opaque) as a literal. Dialyzer's stricter
  # opaqueness checking on OTP 28+ flags this even though it's correct at
  # runtime. Not a real bug: see
  # https://github.com/elixir-lang/elixir/issues/14750 for the same class of
  # false positive with URI/MapSet.
  @dialyzer :no_opaque

  use Gettext.Backend, otp_app: :teacher_coop
end

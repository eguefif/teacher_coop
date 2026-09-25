defmodule Mix.Tasks.Gettext.CheckTranslations do
  @shortdoc "Fails if a locale has missing or fuzzy translations"

  @moduledoc """
  Checks every `.po` file under `priv/gettext` for messages that are not
  translated (empty `msgstr`) or flagged as `fuzzy`.

  The source locale (`en` by default) is skipped, since its msgids are the
  text itself.

      $ mix gettext.check_translations
      $ mix gettext.check_translations --source-locale en

  Run `mix gettext.extract --merge` first so the `.po` files are in sync
  with the code.
  """

  use Mix.Task

  @gettext_dir "priv/gettext"

  @impl true
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [source_locale: :string])
    source_locale = Keyword.get(opts, :source_locale, "en")

    problems =
      Path.join(@gettext_dir, "*/LC_MESSAGES/*.po")
      |> Path.wildcard()
      |> Enum.reject(&(locale(&1) == source_locale))
      |> Enum.flat_map(&check_file/1)

    case problems do
      [] ->
        Mix.shell().info("All translations are complete.")

      problems ->
        Enum.each(problems, fn problem -> Mix.shell().error(problem) end)

        Mix.raise(
          "#{length(problems)} missing or fuzzy translation(s). " <>
            "Fill them in the .po files listed above."
        )
    end
  end

  defp locale(path), do: path |> Path.split() |> Enum.at(-3)

  defp check_file(path) do
    path
    |> Expo.PO.parse_file!()
    |> Map.fetch!(:messages)
    |> Enum.flat_map(fn message ->
      cond do
        Expo.Message.has_flag?(message, "fuzzy") -> ["#{path}: fuzzy: #{msgid(message)}"]
        untranslated?(message) -> ["#{path}: missing: #{msgid(message)}"]
        true -> []
      end
    end)
  end

  defp untranslated?(%Expo.Message.Singular{msgstr: msgstr}), do: blank?(msgstr)

  defp untranslated?(%Expo.Message.Plural{msgstr: msgstr}),
    do: Enum.any?(Map.values(msgstr), &blank?/1)

  defp blank?(strings), do: IO.iodata_to_binary(strings) == ""

  defp msgid(message), do: message.msgid |> IO.iodata_to_binary() |> inspect()
end

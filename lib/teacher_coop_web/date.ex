defmodule TeacherCoopWeb.Date do
  use Gettext, backend: TeacherCoopWeb.Gettext

  def format_time(datetime) do
    {:ok, datetime, _} = DateTime.from_iso8601(datetime)

    case Gettext.get_locale() do
      "en" -> "#{datetime.year} #{get_month_in_string(datetime.month)} #{datetime.day}"
      "fr" -> "#{datetime.day} #{get_month_in_string(datetime.month)} #{datetime.year}"
    end
  end

  defp get_month_in_string(month) do
    case month do
      1 -> gettext("january")
      2 -> gettext("february")
      3 -> gettext("march")
      4 -> gettext("april")
      5 -> gettext("may")
      6 -> gettext("june")
      7 -> gettext("july")
      8 -> gettext("august")
      9 -> gettext("september")
      10 -> gettext("october")
      11 -> gettext("november")
      12 -> gettext("december")
    end
  end
end

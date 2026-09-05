defmodule TeacherCoopWeb.DateTest do
  use ExUnit.Case,
    async: true,
    parameterize:
      for(
        month <-
          Enum.zip([
            ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"],
            [
              "january",
              "february",
              "march",
              "april",
              "may",
              "june",
              "july",
              "august",
              "september",
              "october",
              "november",
              "december"
            ]
          ]),
        do: %{month: month}
      )

  alias TeacherCoopWeb.Date

  setup do
    previous = Gettext.get_locale()
    on_exit(fn -> Gettext.put_locale(previous) end)
    :ok
  end

  describe "format_time/1 with the \"en\" locale" do
    setup do
      Gettext.put_locale("en")
      :ok
    end

    test "formats as \"year month day\"", %{month: month} do
      num_month = elem(month, 0)
      str_month = elem(month, 1)
      assert Date.format_time("2024-#{num_month}-15T10:30:00Z") == "2024 #{str_month} 15"
    end

    test "uses the english month name" do
      assert Date.format_time("2023-12-01T00:00:00Z") == "2023 december 1"
    end

    test "accepts an iso8601 string with an offset" do
      assert Date.format_time("2022-07-04T23:59:59+02:00") == "2022 july 4"
    end
  end

  describe "format_time/1 with the \"fr\" locale" do
    setup do
      Gettext.put_locale("fr")
      :ok
    end

    test "formats as \"day month year\"" do
      assert Date.format_time("2024-01-15T10:30:00Z") == "15 janvier 2024"
    end

    test "translates the month name" do
      assert Date.format_time("2023-09-21T08:00:00Z") == "21 septembre 2023"
    end
  end

  test "raises when the string is not a valid iso8601 datetime" do
    Gettext.put_locale("en")

    assert_raise MatchError, fn -> Date.format_time("not-a-date") end
  end

  test "raises for an unsupported locale" do
    Gettext.put_locale("de")

    assert_raise CaseClauseError, fn -> Date.format_time("2024-01-15T10:30:00Z") end
  end
end

defmodule TeacherCoop.SearchRepoTest do
  use TeacherCoop.DataCase

  describe "SearchRepo" do
    alias TeacherCoop.SearchRepo

    test "camelize_keys" do
      value = ""
      assert "" == SearchRepo.camelize_keys(value)
    end
  end
end

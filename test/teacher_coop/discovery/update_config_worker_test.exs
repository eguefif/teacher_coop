defmodule TeacherCoop.Discovery.UpdateConfigWorkerTest do
  use ExUnit.Case, async: true
  use TeacherCoop.DataCase

  import TeacherCoop.AccountsFixtures, only: [admin_scope_fixture: 0]
  import TeacherCoop.ConfigurationFixtures
  alias TeacherCoop.Discovery.Configuration.Workers.UpdateConfig

  test "perform_job/1 configure meilisearch index" do
    scope = admin_scope_fixture()
    index = index_fixture(scope)
    config = configuration_fixture(scope)

    assert :ok =
             perform_job(UpdateConfig, %{"indexuid" => index.uid, "config_id" => config.id})
  end
end

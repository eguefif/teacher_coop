defmodule TeacherCoop.Discovery.CreateIndexWorkerTest do
  use ExUnit.Case, async: true
  alias TeacherCoop.SearchRepo
  use TeacherCoop.DataCase

  import TeacherCoop.AccountsFixtures, only: [admin_scope_fixture: 0]
  import TeacherCoop.ConfigurationFixtures
  alias TeacherCoop.Discovery.Configuration.Workers.CreateIndex

  setup do
    scope = admin_scope_fixture()
    index = index_fixture(scope)
    SearchRepo.delete_index(index.uid)

    on_exit(:delete_index, fn ->
      SearchRepo.delete_index(index.uid)
    end)

    %{index: index, scope: scope}
  end

  test "perform_job/1 configure meilisearch index", %{index: index, scope: scope} do
    config = configuration_fixture(scope)

    assert :ok =
             perform_job(CreateIndex, %{"indexuid" => index.uid, "config_id" => config.id})
  end
end

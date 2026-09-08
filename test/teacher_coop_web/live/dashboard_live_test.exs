defmodule TeacherCoopWeb.DashboardTest do
  use TeacherCoopWeb.ConnCase

  import Phoenix.LiveViewTest
  alias TeacherCoop.LibraryFixtures
  alias TeacherCoop.AccountsFixtures

  setup :register_and_log_in_admin_user

  defp create_fixtures(%{}) do
    users = create_users()
    documents = create_documents(users)
    %{documents: documents, users: users}
  end

  defp create_users() do
    [AccountsFixtures.add_random_user(), AccountsFixtures.add_random_user()]
  end

  defp create_documents(users) do
    user1 = Enum.at(users, 0)
    user2 = Enum.at(users, 1)

    [
      LibraryFixtures.document_fixture(
        AccountsFixtures.user_scope_fixture(user1),
        %{
          title: "One document",
          description: "One doc description"
        }
      ),
      LibraryFixtures.document_fixture(
        AccountsFixtures.user_scope_fixture(user2),
        %{
          title: "Second document",
          description: "Second doc description"
        }
      )
    ]
  end

  describe "board basic counts" do
    setup [:create_fixtures]

    test "displays documents and user counts", %{conn: conn, documents: documents, users: users} do
      assert {:ok, dashboard_live, _} = live(conn, ~p"/admin")

      assert html =
               dashboard_live
               |> element("#documents-counts")
               |> render()

      html =~ length(documents) |> Integer.to_string()

      assert html =
               dashboard_live
               |> element("#users-counts")
               |> render()

      html =~ length(users) |> Integer.to_string()
    end
  end
end

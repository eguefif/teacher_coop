defmodule TeacherCoop.TeacherNetworking do
  import Ecto.Query, only: [from: 2]

  alias TeacherCoop.Repo
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Accounts.User
  alias TeacherCoop.Colleague

  def get_pending_connections(%Scope{} = scope) do
    user_id = scope.user.id

    query =
      from c in Colleague,
        join: user in User,
        on: user.id == c.user1_id,
        where: c.state == "pending" and c.user2_id == ^user_id,
        select: [id: c.id, fullname: user.fullname]

    Repo.all(query)
  end

  def get_connections(%Scope{} = scope) do
    user_id = scope.user.id

    query =
      from c in Colleague,
        join: user in User,
        on: (user.id == c.user1_id or user.id == c.user2_id) and user.id != ^user_id,
        where: c.state == "accepted" and (c.user2_id == ^user_id or c.user1_id == ^user_id),
        select: %{id: c.id, fullname: user.fullname}

    Repo.all(query)
  end

  def update_connection(%Scope{} = scope, :accept, id) do
    case Repo.get_by(Colleague, id: id, user2_id: scope.user.id) do
      nil ->
        :error

      connection ->
        connection
        |> Colleague.changeset(%{state: "accepted"})
        |> Repo.update()
    end
  end

  def update_connection(%Scope{} = scope, :reject, id) do
    case Repo.get_by(Colleague, id: id, user2_id: scope.user.id) do
      nil ->
        :error

      connection ->
        connection
        |> Colleague.changeset(%{state: "rejected"})
        |> Repo.update()
    end
  end
end

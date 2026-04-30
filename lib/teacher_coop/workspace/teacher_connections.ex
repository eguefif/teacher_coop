defmodule TeacherCoop.Workspace.TeacherNetworking do
  import Ecto.Query, only: [from: 2]

  alias TeacherCoop.Repo
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Accounts.User
  alias TeacherCoop.Workspace.Connection

  def get_pending_connections(%Scope{} = scope) do
    user_id = scope.user.id

    query =
      from c in Connection,
        join: user in User,
        on: user.id == c.user1_id,
        where: c.state == "pending" and c.user2_id == ^user_id,
        select: [id: c.id, fullname: user.fullname]

    Repo.all(query)
  end

  def get_connections(%Scope{} = scope) do
    user_id = scope.user.id

    query =
      from c in Connection,
        join: user in User,
        on: (user.id == c.user1_id or user.id == c.user2_id) and user.id != ^user_id,
        where: c.user2_id == ^user_id or c.user1_id == ^user_id,
        select: %{connection_id: c.id, fullname: user.fullname, state: c.state}

    Repo.all(query)
  end

  def update_connection(%Scope{} = scope, :accept, id) do
    case Repo.get_by(Connection, id: id, user2_id: scope.user.id) do
      nil ->
        :error

      connection ->
        connection
        |> Connection.changeset(%{state: "accepted"})
        |> Repo.update()
    end
  end

  def update_connection(%Scope{} = scope, :reject, id) do
    case Repo.get_by(Connection, id: id, user2_id: scope.user.id) do
      nil ->
        :error

      connection ->
        connection
        |> Connection.changeset(%{state: "rejected"})
        |> Repo.update()
    end
  end

  def create_pending_connection(%Scope{} = scope, invited_user_id) do
    case Repo.get_by(Connection, user1_id: scope.user.id, user2_id: invited_user_id) do
      nil ->
        %Connection{}
        |> Connection.changeset(%{
          user1_id: scope.user.id,
          user2_id: invited_user_id,
          state: "pending"
        })
        |> Repo.insert()

      _ ->
        :already_pending_connection
    end
  end

  def remove_connection_by_id(%Scope{} = _scope, id) do
    # Check if scop.user is admin of the group or in the connection
    IO.inspect(id)

    connection =
      Repo.get_by(Connection,
        id: id
      )

    IO.inspect(connection)
    Repo.delete!(connection)
  end
end

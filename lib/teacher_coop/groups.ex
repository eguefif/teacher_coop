defmodule TeacherCoop.Groups do
  import Ecto.Query, only: [from: 2]

  alias TeacherCoop.Repo
  alias TeacherCoop.Groups.Membership
  alias TeacherCoop.Groups.WorkingGroup
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Accounts.User

  def get_user_groups(%Scope{} = scope) do
    query =
      from gr in WorkingGroup,
        join: m in Membership,
        on: gr.id == m.working_group_id,
        where: m.user_id == ^scope.user.id,
        select: gr

    Repo.all(query)
  end

  def get_group!(%Scope{} = scope, id) do
    query =
      from group in WorkingGroup,
        join: memberships in Membership,
        on: memberships.user_id == ^scope.user.id and group.id == ^id,
        where: memberships.role == "admin" and group.id == ^id,
        select: group,
        limit: 1

    Repo.one!(query)
  end

  def get_group_for_member!(%Scope{} = scope, id) do
    query =
      from group in WorkingGroup,
        join: m in Membership,
        on: m.working_group_id == group.id and m.user_id == ^scope.user.id,
        where: group.id == ^id,
        select: group,
        limit: 1

    Repo.one!(query)
  end

  def list_members(group_id) do
    query =
      from m in Membership,
        join: u in User,
        on: u.id == m.user_id,
        where: m.working_group_id == ^group_id,
        select: %{role: m.role, email: u.email, fullname: u.fullname, user_id: m.user_id}

    Repo.all(query)
  end

  def change_group(%WorkingGroup{} = group, attrs \\ %{}) do
    WorkingGroup.changeset(group, attrs)
  end

  def create_group(%Scope{} = scope, attrs) do
    Repo.transaction(fn ->
      group =
        %WorkingGroup{}
        |> WorkingGroup.changeset(attrs)
        |> Repo.insert!()

      %Membership{}
      |> Membership.changeset(%{role: "admin"}, group, scope)
      |> Repo.insert!()
    end)
  end

  def update_group(%Scope{} = _scope, %WorkingGroup{} = group, attrs \\ %{}) do
    # TODO: check if user is group admin
    group |> WorkingGroup.changeset(attrs) |> Repo.update()
  end
end

defmodule TeacherCoop.Groups do
  import Ecto.Query, only: [from: 2]
  alias TeacherCoop.Repo
  alias TeacherCoop.Groups.Membership
  alias TeacherCoop.Groups.WorkingGroup
  alias TeacherCoop.Accounts.Scope

  def get_user_groups(%Scope{} = scope) do
    query =
      from gr in WorkingGroup,
        join: m in Membership,
        on: gr.id == m.working_group_id,
        where: m.user_id == ^scope.user.id,
        select: gr

    Repo.all(query)
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
end

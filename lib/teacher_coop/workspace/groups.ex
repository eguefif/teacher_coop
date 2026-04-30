defmodule TeacherCoop.Workspace.Groups do
  import Ecto.Query, only: [from: 2]

  alias TeacherCoop.Repo
  alias TeacherCoop.Workspace.Groups.Membership
  alias TeacherCoop.Workspace.Groups.WorkingGroup
  alias TeacherCoop.Workspace.Groups.DocumentWorkingGroup
  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Accounts.User
  alias TeacherCoop.Workspace.Document

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
        select: %{
          membership_id: m.id,
          role: m.role,
          email: u.email,
          fullname: u.fullname,
          user_id: m.user_id
        }

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
      |> Membership.changeset(%{
        role: "admin",
        working_group_id: group.id,
        user_id: scope.user.id
      })
      |> Repo.insert!()
    end)
  end

  def update_group(%Scope{} = _scope, %WorkingGroup{} = group, attrs \\ %{}) do
    # TODO: check if user is group admin
    group |> WorkingGroup.changeset(attrs) |> Repo.update()
  end

  def invite_user_to_group(%Scope{} = _scope, group_id, user_id) do
    # TODO: check if scope.user is admin // Also display the add user if the user is admin
    %Membership{}
    |> Membership.changeset(%{
      role: "admin",
      working_group_id: group_id,
      user_id: user_id
    })
    |> Repo.insert!()
  end

  def is_admin?(%Scope{} = scope, group_id) do
    query =
      from m in Membership,
        where: m.user_id == ^scope.user.id and m.role == "admin" and m.id == ^group_id

    Repo.exists?(query)
  end

  def remove_membership_by_id(%Scope{} = _scope, id) do
    # Check if scop.user is admin of the group or in the connection
    connection =
      Repo.get_by(Membership,
        id: id
      )

    Repo.delete!(connection)
  end

  def get_pending_group_invitations(%Scope{} = scope) do
    query =
      from m in Membership,
        join: gr in WorkingGroup,
        on: gr.id == m.working_group_id,
        where: m.user_id == ^scope.user.id and m.role == "invited",
        select: %{membership_id: m.id, group_name: gr.name}

    Repo.all(query)
  end

  def accept_invitation(%Scope{} = scope, id) do
    invitation = Repo.get_by!(Membership, user_id: scope.user.id, id: id)

    invitation
    |> Membership.changeset(%{
      role: "member",
      working_group_id: invitation.working_group_id,
      user_id: invitation.user_id
    })
    |> Repo.update()
    |> elem(0)
  end

  def reject_invitation(%Scope{} = scope, id) do
    invitation = Repo.get_by!(Membership, user_id: scope.user.id, id: id)

    invitation
    |> Membership.changeset(%{
      role: "rejected",
      working_group_id: invitation.working_group_id,
      user_id: invitation.user_id
    })
    |> Repo.update()
    |> elem(0)
  end

  def get_document_groups(%Scope{} = scope, document_id) do
    query =
      from m in Membership,
        join: gr in WorkingGroup,
        on: gr.id == m.working_group_id,
        left_join: dg in DocumentWorkingGroup,
        on: gr.id == dg.working_group_id and ^document_id == dg.document_id,
        where: m.user_id == ^scope.user.id,
        select: %{id: gr.id, name: gr.name, shared: not is_nil(dg.id)}

    Repo.all(query)
  end

  def share_document(%Scope{} = scope, working_group_id, document_id) do
    query =
      from gr in WorkingGroup,
        join: m in Membership,
        on: gr.id == m.working_group_id,
        where: gr.id == ^working_group_id and m.user_id == ^scope.user.id

    working_group = Repo.one!(query)

    %DocumentWorkingGroup{}
    |> DocumentWorkingGroup.changeset(%{
      working_group_id: working_group.id,
      document_id: document_id
    })
    |> Repo.insert!()
  end

  def unshare_document(%Scope{} = scope, working_group_id, document_id) do
    query =
      from dg in DocumentWorkingGroup,
        join: gr in WorkingGroup,
        on: gr.id == dg.working_group_id,
        join: m in Membership,
        on: gr.id == m.working_group_id,
        where:
          dg.working_group_id == ^working_group_id and dg.document_id == ^document_id and
            m.user_id == ^scope.user.id

    document_working_group = Repo.one!(query)
    Repo.delete!(document_working_group)
  end

  def get_shared_documents(working_group_id) do
    query =
      from d in Document,
        join: dg in DocumentWorkingGroup,
        on: dg.working_group_id == ^working_group_id

    Repo.all(query)
  end
end

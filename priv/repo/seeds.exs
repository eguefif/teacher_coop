# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TeacherCoop.Repo.insert!(%TeacherCoop.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TeacherCoop.Repo
alias TeacherCoop.Accounts.User
alias TeacherCoop.Groups.WorkingGroup
alias TeacherCoop.Groups.Membership
alias TeacherCoop.Colleague

user =
  Repo.insert!(%User{
    email: "admin@localhost.fr",
    fullname: "Robert De Fouca"
  })

user2 =
  Repo.insert!(%User{
    email: "gemini@localhost.fr",
    fullname: "Gemini Jupiter"
  })

Repo.insert!(%Colleague{
  user1_id: user2.id,
  user2_id: user.id,
  state: "pending"
})

group =
  Repo.insert!(%WorkingGroup{
    name: "Hello, World"
  })

Repo.insert!(%Membership{
  user_id: user.id,
  working_group_id: group.id,
  role: "admin"
})

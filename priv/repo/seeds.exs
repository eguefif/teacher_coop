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

for {email, fullname} <- [
  {"marie@localhost.fr", "Marie Curie"},
  {"albert@localhost.fr", "Albert Einstein"},
  {"ada@localhost.fr", "Ada Lovelace"},
  {"nikola@localhost.fr", "Nikola Tesla"},
  {"linus@localhost.fr", "Linus Torvalds"},
  {"grace@localhost.fr", "Grace Hopper"},
  {"alan@localhost.fr", "Alan Turing"},
  {"richard@localhost.fr", "Richard Feynman"},
  {"sophie@localhost.fr", "Sophie Germain"},
  {"charles@localhost.fr", "Charles Darwin"},
  {"elena@localhost.fr", "Elena Vasquez"},
  {"omar@localhost.fr", "Omar Khalid"},
  {"priya@localhost.fr", "Priya Sharma"},
  {"lucas@localhost.fr", "Lucas Moreau"},
  {"amara@localhost.fr", "Amara Diallo"},
  {"yuki@localhost.fr", "Yuki Tanaka"},
  {"felix@localhost.fr", "Felix Schneider"},
  {"ingrid@localhost.fr", "Ingrid Larsen"},
  {"marco@localhost.fr", "Marco Ricci"},
  {"chloe@localhost.fr", "Chloe Dubois"}
] do
  Repo.insert!(%User{email: email, fullname: fullname})
end

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

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

alias TeacherCoop.Library
alias TeacherCoop.Accounts

# TODO: Create a user

user_attrs = %{:email => "rob@rob.org"}

{:ok, user} = Accounts.register_user(user_attrs)

user_scope = Accounts.Scope.for_user(user)

# TODO: Create 3 documents for this user

attrs = [
  %{
    :title => "Fraction en ligne",
    :description => "Some fraction description"
  },
  %{
    :title => "Les verbes pronominaux",
    :description => "Séance de conjugaison"
  },
  %{
    :title => "Le système métrique",
    :description => "Présentation du système métrique et son histoire."
  }
]

attrs
|> Enum.map(&Library.create_document(user_scope, &1))

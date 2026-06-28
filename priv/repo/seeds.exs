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
user_email = "eguefif@fastmail.com"

user_attrs = %{:email => user_email}

user =
  case Accounts.register_user(user_attrs) do
    {:ok, user} -> user
    {:error, _} -> Accounts.get_user_by_email(user_email)
  end

user_scope = Accounts.Scope.for_user(user)

attrs = [
  %{
    :title => "Fraction en ligne",
    :description => "Some fraction description",
    :institution_type => "École élémentaire"
  },
  %{
    :title => "Addition de fraction",
    :description =>
      "Séance qui traite des additions des fractions et des techniques de calculs mentales en lien",
    :institution_type => "École élémentaire"
  },
  %{
    :title => "Problèmes de fraction",
    :description =>
      "Liste de problèmes de difficultés croissantes faisant beaucoup usage de représentation",
    :institution_type => "École élémentaire"
  },
  %{
    :title => "Introduction aux nombres décimaux",
    :description =>
      "Séance qui fait le lien entre les fractions décimales et les nombres décimaux.",
    :institution_type => "École élémentaire"
  },
  %{
    :title => "Les verbes pronominaux",
    :description => "Séance de conjugaison",
    :institution_type => "École élémentaire"
  },
  %{
    :title => "Le système métrique",
    :description => "Présentation du système métrique et son histoire.",
    :institution_type => "École maternelle"
  }
]

attrs
|> Enum.map(&Library.create_document(user_scope, &1))

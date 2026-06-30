defmodule TeacherCoop.Repo.Seeds.MainSeed do
  alias TeacherCoop.Library
  alias TeacherCoop.Accounts

  def seed() do
    user_email = "eguefif@fastmail.com"
    fullname = "Emmanuel Guefif"

    user =
      case Accounts.register_user(%{:email => user_email}) do
        {:ok, user} -> user
        {:error, _} -> Accounts.get_user_by_email(user_email)
      end

    user =
      case Accounts.update_user(TeacherCoop.Accounts.Scope.for_user(user), %{
             :fullname => fullname
           }) do
        {:ok, user} -> user
        {:error, _} -> Accounts.get_user_by_email(user_email)
      end

    user_scope = Accounts.Scope.for_user(user)

    attrs = [
      %{
        :title => "Fraction en ligne",
        :description =>
          "Séance d'introduction aux fractions à l'aide d'outils numériques interactifs. Les élèves manipulent des fractions sur une droite graduée et explorent les notions de numérateur et dénominateur à travers des activités en ligne guidées.",
        :institution_type => "École élémentaire"
      },
      %{
        :title => "Addition de fraction",
        :description =>
          "Séance qui traite des additions des fractions et des techniques de calculs mentales en lien. Les élèves apprennent à additionner des fractions de même dénominateur puis de dénominateurs différents, avec des exercices progressifs et des stratégies de calcul mental adaptées.",
        :institution_type => "École élémentaire"
      },
      %{
        :title => "Problèmes de fraction",
        :description =>
          "Liste de problèmes de difficultés croissantes faisant beaucoup usage de représentation. Chaque problème invite les élèves à mobiliser des schémas, des dessins ou des partages concrets pour donner du sens aux fractions dans des contextes variés de la vie quotidienne.",
        :institution_type => "École élémentaire"
      },
      %{
        :title => "Introduction aux nombres décimaux",
        :description =>
          "Séance qui fait le lien entre les fractions décimales et les nombres décimaux. À partir de situations concrètes (mesures, monnaie), les élèves découvrent la notation décimale et comprennent la correspondance entre 1/10, 1/100 et leurs écritures à virgule.",
        :institution_type => "École élémentaire"
      },
      %{
        :title => "Les verbes pronominaux",
        :description =>
          "Séance de conjugaison centrée sur les verbes pronominaux au présent et au passé composé. Les élèves identifient les pronoms réfléchis, s'exercent à conjuguer des verbes courants comme se lever ou se laver, et travaillent l'accord du participe passé en contexte.",
        :institution_type => "École élémentaire"
      },
      %{
        :title => "Le système métrique",
        :description =>
          "Présentation du système métrique et son histoire. Les élèves découvrent l'origine révolutionnaire du mètre, explorent les principales unités de longueur, masse et contenance, et s'entraînent à effectuer des conversions à l'aide de tableaux et d'exercices pratiques.",
        :institution_type => "École maternelle"
      }
    ]

    true =
      attrs
      |> Enum.map(&Library.create_document(user_scope, &1))
      |> Enum.map(&elem(&1, 0))
      |> Enum.all?(&(&1 == :ok))
  end
end

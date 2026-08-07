defmodule TeacherCoop.Repo.Seeds.MainSeed do
  import Ecto.Query, warn: false

  alias TeacherCoop.Library
  alias TeacherCoop.Curriculum.Objective
  alias TeacherCoop.Discovery.Search
  alias TeacherCoop.Accounts
  alias TeacherCoop.Repo

  def seed() do
    user_email = "robert_do@lost.com"
    fullname = "Robert Do"

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
        :institution_type => "École élémentaire",
        :grade => "CE2",
        :subject => "mathématiques"
      },
      %{
        :title => "Addition de fraction",
        :description =>
          "Séance qui traite des additions des fractions et des techniques de calculs mentales en lien. Les élèves apprennent à additionner des fractions de même dénominateur puis de dénominateurs différents, avec des exercices progressifs et des stratégies de calcul mental adaptées.",
        :institution_type => "École élémentaire",
        :grade => "CE2",
        :subject => "mathématiques"
      },
      %{
        :title => "Problèmes de fraction",
        :description =>
          "Liste de problèmes de difficultés croissantes faisant beaucoup usage de représentation. Chaque problème invite les élèves à mobiliser des schémas, des dessins ou des partages concrets pour donner du sens aux fractions dans des contextes variés de la vie quotidienne.",
        :institution_type => "École élémentaire",
        :grade => "CE2",
        :subject => "mathématiques"
      },
      %{
        :title => "Introduction aux nombres décimaux",
        :description =>
          "Séance qui fait le lien entre les fractions décimales et les nombres décimaux. À partir de situations concrètes (mesures, monnaie), les élèves découvrent la notation décimale et comprennent la correspondance entre 1/10, 1/100 et leurs écritures à virgule.",
        :institution_type => "École élémentaire",
        :grade => "CM1",
        :subject => "mathématiques"
      },
      %{
        :title => "Les verbes pronominaux",
        :description =>
          "Séance de conjugaison centrée sur les verbes pronominaux au présent et au passé composé. Les élèves identifient les pronoms réfléchis, s'exercent à conjuguer des verbes courants comme se lever ou se laver, et travaillent l'accord du participe passé en contexte.",
        :institution_type => "École élémentaire",
        :grade => "CM1",
        :subject => "français"
      },
      %{
        :title => "Le système métrique",
        :description =>
          "Présentation du système métrique et son histoire. Les élèves découvrent l'origine révolutionnaire du mètre, explorent les principales unités de longueur, masse et contenance, et s'entraînent à effectuer des conversions à l'aide de tableaux et d'exercices pratiques.",
        :institution_type => "École maternelle",
        :grade => "CM2",
        :subject => "mathématiques"
      }
    ]

    true =
      attrs
      |> Enum.map(fn document_attrs ->
        {subject, document_attrs} = Map.pop(document_attrs, :subject)
        objective_ids = sample_objective_ids(document_attrs.grade, subject)

        Library.create_document(user_scope, document_attrs, objective_ids)
      end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.all?(&(&1 == :ok))

    seed_searches(user)
  end

  defp seed_searches(user) do
    attrs = [
      %{
        search_terms: "fraction ce2",
        hits_count: 5,
        success: true,
        success_click_position: 1,
        dwell_time: 8_500,
        document_index: "documents"
      },
      %{
        search_terms: "addition fractions",
        hits_count: 4,
        success: true,
        success_click_position: 2,
        dwell_time: 12_300,
        document_index: "documents"
      },
      %{
        search_terms: "nombres décimaux cm1",
        hits_count: 3,
        success: true,
        success_click_position: 1,
        dwell_time: 6_100,
        document_index: "documents"
      },
      %{
        search_terms: "verbes pronominaux",
        hits_count: 6,
        success: true,
        success_click_position: 3,
        dwell_time: 15_400,
        document_index: "documents"
      },
      %{
        search_terms: "système métrique",
        hits_count: 2,
        success: true,
        success_click_position: 1,
        dwell_time: 4_200,
        document_index: "documents"
      },
      %{
        search_terms: "mesures et conversions",
        hits_count: 4,
        success: true,
        success_click_position: 4,
        dwell_time: 18_700,
        document_index: "documents"
      },
      %{
        search_terms: "problèmes de fractions",
        hits_count: 8,
        success: false,
        success_click_position: nil,
        dwell_time: 22_000,
        document_index: "documents"
      },
      %{
        search_terms: "géométrie cm2",
        hits_count: 0,
        success: false,
        success_click_position: nil,
        dwell_time: 3_000,
        document_index: "documents"
      },
      %{
        search_terms: "conjugaison présent",
        hits_count: 5,
        success: false,
        success_click_position: nil,
        dwell_time: 9_800,
        document_index: "documents"
      },
      %{
        search_terms: "dictée cm1",
        hits_count: 0,
        success: false,
        success_click_position: nil,
        dwell_time: 2_500,
        document_index: "documents"
      }
    ]

    attrs
    |> Enum.each(fn search_attrs ->
      %Search{}
      |> Ecto.Changeset.change(search_attrs)
      |> Ecto.Changeset.put_change(:user_id, user.id)
      |> Repo.insert!()
    end)
  end

  defp sample_objective_ids(grade, subject, count \\ 3) do
    from(o in Objective, where: o.grade == ^grade and o.subject == ^subject, select: o.id)
    |> Repo.all()
    |> Enum.take_random(count)
  end
end

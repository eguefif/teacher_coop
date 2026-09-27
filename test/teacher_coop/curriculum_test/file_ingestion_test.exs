defmodule TeacherCoop.CurriculumTest.FileIngestionWorkerTest do
  use TeacherCoop.DataCase

  alias TeacherCoop.Curriculum.FileIngestionWorker
  alias TeacherCoop.Curriculum

  @file_content """
  lecture - CP
  Identifier les mots de manière de plus en plus aisée.
  Décoder et encoder 12 à 15 correspondances graphophonémiques (CGP) régulières, fréquentes et aisément prononçables.
  Déchiffrer des syllabes, des mots puis des phrases en fonction de la progression de l’apprentissage des CGP.
  Décoder et encoder de 25 à 30 CGP.
  Avoir pris conscience de la présence de lettres finales muettes et s’appuyer sur le sens des mots pour les déchiffrer correctement.
  Mémoriser les mots fréquents et réguliers.
  Déchiffrer entre 15 et 30 mots par minute.
  Décoder 30 mots par minute au minimum fin CP, sans préparation, 50 après préparation.
  Lire à voix haute.
  Oraliser les syllabes déchiffrées et encodées, puis les mots
  Oraliser régulièrement les mots et phrases déchiffrés et encodés.
  S’entrainer à lire des textes déchiffrables de manière à automatiser sa lecture.
  Lire après préparation un texte adapté à son niveau de lecture avec une vitesse de 30 mots par minute au minimum sans préparation, 50 après préparation.
  Identifier les marques de ponctuation et les prendre en compte sur un texte préparé.
  Amorcer une lecture expressive.
  Dégager le sens global d’un texte entendu ou lu de façon autonome.
  Identifier les mots inconnus dans un texte et chercher à leur donner un sens.
  Se repérer dans la chaine anaphorique (qui relie un nom à sa ou ses reprise(s) pronominale(s) ou à d’autres noms de sens équivalent).
  Comprendre ce qui est implicite (inférences simples).
  Justifier ses réponses par un retour au texte.
  Lire et comprendre en autonomie un texte narratif, informatif ou prescriptif d’une dizaine de lignes..
  Devenir lecteur.
  Lire 5 à 10 œuvres complètes et variées issues du patrimoine et de la littérature de jeunesse (albums, romans, contes, fables, poèmes, pièces de théâtre et documentaires).
  Repérer et reconnaitre des types de personnages.
  Aller vers les livres et être capable d’en choisir à titre personnel.
  Relier ses lectures à son expérience personnelle, être en mesure d’établir des liens entre ses différentes lectures (mise en réseau).
  Fréquenter régulièrement des lieux de lecture et se familiariser avec eux, rencontrer des acteurs du livre.

  lecture - CE1
  Identifier les mots de manière de plus en plus aisé.
  Automatiser le décodage des correspondances graphophonémiques (CGP) apprises au CP.
  Décoder toutes les CGP y compris les plus complexes.
  Avoir mémorisé l’ensemble des CGP dans tous les types d’écriture, en particulier celles des sons proches (en encodage et décodage).
  Identifier directement l’ensemble des mots courants et déchiffrer avec exactitude les mots nouveaux dont le décodage n’a pas encore été automatisé.
  Lire un texte adapté à son niveau de lecture avec une vitesse de 70 mots par minute.
  Lire des textes narratifs, documentaires et prescriptifs en respectant tous les signes de ponctuation et les groupes de souffle.
  Lire de manière expressive.
  Comprendre un texte.
  Dégager le sens global d’un texte lu, de façon autonome, à la suite d’une séance dédiée à la compréhension.
  Développer des stratégies pour élucider le sens des mots et des expressions inconnus.
  Se repérer dans la chaine anaphorique (qui relie un nom à sa ou ses reprise(s) pronominale(s) ou à d’autres noms de sens équivalent) et s’appuyer sur le sens du texte pour résoudre des ambigüités.
  Comprendre ce qui est implicite dans le texte (inférences) dans des cas simples.
  Justifier ses réponses par un retour au texte.
  Lire et comprendre en autonomie un texte narratif, informatif ou prescriptif d’une quinzaine de lignes.
  Devenir lecteur.
  Se familiariser aux différents genres et types de textes.
  Lire 5 à 10 œuvres complètes et variées issues du patrimoine et de la littérature de jeunesse (albums, romans, contes, fables, poèmes, pièces de théâtre et documentaires).
  Faire preuve d’initiative dans ses lectures personnelles en empruntant des livres en fonction de ses gouts.
  Relier ses lectures à son expérience personnelle, être en mesure d’établir des liens entre ses différentes lectures (mise en réseau).
  """

  @goal_ce1_check "Développer des stratégies pour élucider le sens des mots et des expressions inconnus."
  @goal_cp_check "Fréquenter régulièrement des lieux de lecture et se familiariser avec eux, rencontrer des acteurs du livre."

  @total_objectives 47
  @year 2022
  @subject "français"

  test "perform_job/1" do
    attrs = %{year: @year, subject: @subject, file_content: @file_content}
    assert :ok = perform_job(FileIngestionWorker, attrs)

    objectives = Curriculum.list_objectives_by(year: @year)
    assert length(objectives) == @total_objectives

    assert objective = Curriculum.get_objective_by!(goal: @goal_ce1_check, year: @year)
    assert objective.subject == @subject
    assert objective.year == @year

    assert objective = Curriculum.get_objective_by!(goal: @goal_cp_check, year: @year)
    assert objective.subject == @subject
    assert objective.year == @year
  end
end

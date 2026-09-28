defmodule TeacherCoop.CurriculumTest.FileIngestionWorkerTest do
  use TeacherCoop.DataCase

  import TeacherCoop.CurriculumFixtures
  alias TeacherCoop.Curriculum.FileIngestionWorker
  alias TeacherCoop.Curriculum

  @file_content """
  lecture - CP
  Lire un livre tout seul.
  Lire en autonome.
  Déchiffrer les sons simples.

  lecture - CE1
  Livre un livre en entier.
  Déchiffre tous les sons.
  Repérer les sons dans la phrase.
  """

  @invalid_file_content """
  lecture - CP
  Lire un livre tout seul.
  Lire un livre tout seul.
  Lire en autonome.
  Déchiffrer les sons simples.

  lecture - CE1
  Livre un livre en entier.
  Déchiffre tous les sons.
  Repérer les sons dans la phrase.
  """

  @goal_ce1_check "Repérer les sons dans la phrase."
  @goal_cp_check "Lire un livre tout seul."

  @total_objectives 6
  @year 2020
  @subject "français"

  test "perform_job/1" do
    ingestion = curriculum_ingestion_fixture()

    attrs = %{
      ingestion_id: ingestion.id,
      year: @year,
      subject: @subject,
      filecontent: @file_content
    }

    assert :ok = perform_job(FileIngestionWorker, attrs)

    objectives = Curriculum.list_objectives_by(year: @year)
    assert length(objectives) == @total_objectives

    assert objective = Curriculum.get_objective_by!(goal: @goal_ce1_check, year: @year)
    assert objective.subject == @subject
    assert objective.year == @year

    assert objective = Curriculum.get_objective_by!(goal: @goal_cp_check, year: @year)
    assert objective.subject == @subject
    assert objective.year == @year

    ingestion = Curriculum.get_curriculum_ingestion(ingestion.id)
    assert ingestion.state == "finished"
  end

  test "perform_job/1 failed to persist objectives" do
    ingestion = curriculum_ingestion_fixture()

    attrs = %{
      ingestion_id: ingestion.id,
      year: @year,
      subject: @subject,
      filecontent: @invalid_file_content
    }

    assert {:error, sentry_id} = perform_job(FileIngestionWorker, attrs)

    ingestion = Curriculum.get_curriculum_ingestion(ingestion.id)
    assert ingestion.state == "error"
    assert ingestion.sentry_id == sentry_id
  end
end

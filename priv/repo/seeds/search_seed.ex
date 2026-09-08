defmodule TeacherCoop.Repo.Seeds.SearchSeed do
  @moduledoc """
  Seeds the `searches` table with the data used by the search-metrics dashboard.

  It has two sections:

    * `seed_sample_searches/1` - a small, hand written set of mixed searches
      (success / failed, with and without hits). Handy for eyeballing the search
      list and the "click position" / "dwell time" metrics.

    * `seed_zero_result_searches/1` - a batch of zero-result searches
      (`hits_count: 0`, `state: "failed"`). They are spread over the last 10 days
      (today included) with several entries per day so the "searches with no
      results" dashboard has something realistic to chart over time.
  """

  import Ecto.Query, warn: false

  alias TeacherCoop.Discovery.Search
  alias TeacherCoop.Repo

  # How far back the zero-result searches go (today included), and how many we
  # want per day.
  @days_back 10
  @min_per_day 4
  @max_per_day 9

  # Searches are spread inside this daily window (local-ish, stored as UTC).
  @window_start ~T[08:00:00]
  @window_seconds 12 * 60 * 60

  @doc """
  Seed every search fixture for the given `user`.
  """
  def seed(user) do
    seed_sample_searches(user)
    seed_zero_result_searches(user)
  end

  @doc """
  Insert the small mixed set of sample searches (inserted "now").
  """
  def seed_sample_searches(user) do
    [
      %{
        search_terms: "fraction ce2",
        hits_count: 5,
        state: "success",
        success_click_position: 1,
        dwell_time: 8_500,
        document_index: "documents"
      },
      %{
        search_terms: "addition fractions",
        hits_count: 4,
        state: "success",
        success_click_position: 2,
        dwell_time: 12_300,
        document_index: "documents"
      },
      %{
        search_terms: "nombres décimaux cm1",
        hits_count: 3,
        state: "success",
        success_click_position: 1,
        dwell_time: 6_100,
        document_index: "documents"
      },
      %{
        search_terms: "verbes pronominaux",
        hits_count: 6,
        state: "success",
        success_click_position: 3,
        dwell_time: 15_400,
        document_index: "documents"
      },
      %{
        search_terms: "système métrique",
        hits_count: 2,
        state: "success",
        success_click_position: 1,
        dwell_time: 4_200,
        document_index: "documents"
      },
      %{
        search_terms: "mesures et conversions",
        hits_count: 4,
        state: "failed",
        success_click_position: 4,
        dwell_time: 18_700,
        document_index: "documents"
      },
      %{
        search_terms: "problèmes de fractions",
        hits_count: 8,
        state: "failed",
        success_click_position: nil,
        dwell_time: 22_000,
        document_index: "documents"
      },
      %{
        search_terms: "géométrie cm2",
        hits_count: 0,
        state: "failed",
        success_click_position: nil,
        dwell_time: 3_000,
        document_index: "documents"
      },
      %{
        search_terms: "conjugaison présent",
        hits_count: 5,
        state: "failed",
        success_click_position: nil,
        dwell_time: 9_800,
        document_index: "documents"
      },
      %{
        search_terms: "dictée cm1",
        hits_count: 0,
        state: "failed",
        success_click_position: nil,
        dwell_time: 2_500,
        document_index: "documents"
      }
    ]
    |> Enum.each(&insert_search(&1, user))
  end

  @doc """
  Insert 10 days of zero-result searches (today included), several per day.

  The number of searches per day and the search terms are derived
  deterministically from the day offset, so running the seed twice produces the
  same shape (just duplicated rows).
  """
  def seed_zero_result_searches(user) do
    today = Date.utc_today()
    pool = zero_result_terms()
    pool_size = length(pool)

    for day_offset <- 0..(@days_back - 1) do
      date = Date.add(today, -day_offset)
      count = per_day_count(day_offset)
      start = rem(day_offset * @max_per_day, pool_size)

      for index <- 0..(count - 1) do
        term = Enum.at(pool, rem(start + index, pool_size))

        %{
          search_terms: term,
          hits_count: 0,
          state: "failed",
          success_click_position: nil,
          dwell_time: 700 + rem(:erlang.phash2({term, index}), 4_500),
          document_index: "documents",
          inserted_at: search_time(date, index, count)
        }
        |> insert_search(user)
      end
    end
  end

  # Between @min_per_day and @max_per_day, varying day to day.
  defp per_day_count(day_offset) do
    span = @max_per_day - @min_per_day + 1
    @min_per_day + rem(day_offset * 3 + 1, span)
  end

  # Spread `count` searches across the daily window, with a little jitter so the
  # timestamps are not perfectly regular.
  defp search_time(date, index, count) do
    step = div(@window_seconds, count)
    jitter = rem(:erlang.phash2({date, index}), max(step, 1))
    offset = index * step + jitter

    {:ok, naive} = NaiveDateTime.new(date, @window_start)

    naive
    |> NaiveDateTime.add(offset, :second)
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.truncate(:second)
  end

  defp insert_search(attrs, user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    {inserted_at, attrs} = Map.pop(attrs, :inserted_at, now)

    attrs = Map.merge(attrs, %{inserted_at: inserted_at, updated_at: inserted_at})

    %Search{}
    |> Ecto.Changeset.change(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert!()
  end

  # Plausible French classroom queries that do not match anything in the seeded
  # library, so they always come back with zero results.
  defp zero_result_terms do
    [
      "photosynthèse cycle 3",
      "révolution française 6ème",
      "conjugaison imparfait ce1",
      "tables de multiplication ce1",
      "accord du participe passé être",
      "figures de style seconde",
      "théorème de pythagore 4ème",
      "aire du disque cm2",
      "programme histoire cm1",
      "poésie sur l'automne cycle 2",
      "dictée préparée ce2",
      "vocabulaire anglais les couleurs",
      "verbe avoir au présent cp",
      "symétrie axiale ce2",
      "les solides en géométrie cm1",
      "nombres relatifs 5ème",
      "proportionnalité 6ème",
      "climat et météo cm1",
      "volcans et séismes 4ème",
      "cycle de l'eau cm2",
      "chaîne alimentaire ce2",
      "problèmes multiplicatifs cm1",
      "lecture compréhension ce1",
      "sons complexes gn cp",
      "écriture cursive maternelle",
      "numération jusqu'à 100 cp",
      "la monnaie en euros ce1",
      "lire l'heure ce2",
      "les angles cm1",
      "périmètre d'un polygone cm2",
      "calcul mental cp",
      "compléments à 10 cp",
      "additions posées ce1",
      "soustraction avec retenue ce2",
      "division euclidienne cm1",
      "multiplication à deux chiffres cm2",
      "encadrer un nombre entier cm1",
      "les homophones grammaticaux cm2",
      "passé composé auxiliaire avoir cm1",
      "futur simple ce2",
      "nature des mots grammaire ce2",
      "fonction sujet verbe ce2",
      "champ lexical de la forêt cm1",
      "expression écrite portrait cm2",
      "compréhension de texte documentaire cm1",
      "les préfixes et suffixes cm1",
      "famille de mots ce2",
      "accents é è ê cp",
      "le pluriel des noms en ou ce2",
      "les déterminants possessifs cm1",
      "phrase interrogative ce1",
      "ponctuation dialogue cm2",
      "résumé de texte 6ème",
      "carte de France régions cm1",
      "les fleuves français cm2",
      "la préhistoire ce2",
      "gaulois et romains cm1",
      "moyen âge châteaux forts cm1",
      "première guerre mondiale cm2",
      "seconde guerre mondiale cm2",
      "la ve république emc",
      "droits de l'enfant emc",
      "les déchets et le recyclage ce2",
      "développement durable cm2",
      "le squelette humain cm1",
      "la digestion cm2",
      "la respiration cycle 3",
      "les états de la matière ce2",
      "électricité circuit simple cm1",
      "les aimants ce2",
      "ombre et lumière cm1",
      "germination de la graine ce1",
      "le système solaire cm2",
      "phases de la lune cm1",
      "classification des animaux ce2",
      "vertébrés et invertébrés cm1",
      "régimes alimentaires des animaux ce1",
      "arts visuels land art cycle 3",
      "histoire des arts renaissance cm2",
      "éducation musicale rythme ce2",
      "chant choral cycle 2",
      "arts plastiques portrait cubiste cm2",
      "eps parcours gymnique cp",
      "règles du jeu de la balle au prisonnier",
      "danse de création cycle 3",
      "course d'orientation cm1",
      "natation savoir nager cm2",
      "anglais se présenter ce2",
      "anglais la météo cm1",
      "anglais les nombres jusqu'à 20 ce2",
      "anglais chanson happy birthday cp",
      "espagnol saluer 6ème",
      "allemand les couleurs 6ème",
      "programmation scratch cm2",
      "algorithme débranché cm1",
      "utiliser un tableur cm2",
      "rechercher sur internet cm1",
      "identité numérique emc cm2",
      "graphique et tableau de données cm1",
      "statistiques diagramme en barres cm2",
      "conversion litres millilitres cm1",
      "conversion grammes kilogrammes cm2",
      "durées et horaires problèmes cm2",
      "monnaie rendre la monnaie ce2",
      "fractions partage de gâteau ce1",
      "double et moitié ce1",
      "suite numérique de 2 en 2 cp",
      "repérage sur quadrillage ce1",
      "tracer à la règle ce1",
      "reproduction de figures cm1",
      "programme de construction cm2",
      "patron du cube cm2",
      "vocabulaire géométrique cm1",
      "les fractions supérieures à 1 cm2",
      "arrondir un nombre décimal cm2",
      "comparer des décimaux cm2",
      "additionner des décimaux cm2",
      "table des 7 ce2",
      "critères de divisibilité cm2",
      "nombres jusqu'au million cm1",
      "grands nombres cm2",
      "problèmes à étapes cm1",
      "sens de la division cm1"
    ]
  end
end

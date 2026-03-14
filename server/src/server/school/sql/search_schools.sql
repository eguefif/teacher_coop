-- search_schools
-- arg1: String search parameters
SELECT
    id,
    name,
    code_departement,
    city_name,
    word_similarity (lower(unaccent ($1)), search) AS score
FROM
    french_schools
WHERE
    lower(unaccent ($1)) <% search
ORDER BY
    SCORE DESC
LIMIT 20;


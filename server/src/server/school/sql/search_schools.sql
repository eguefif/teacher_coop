-- search_schools
-- arg1: String search parameters
SELECT
    id,
    name,
    code_departement,
    city_name,
    similarity (search, lower(unaccent ($1))) AS score
FROM
    french_schools
WHERE
    search % lower(unaccent ($1))
ORDER BY
    SCORE DESC
LIMIT 10;


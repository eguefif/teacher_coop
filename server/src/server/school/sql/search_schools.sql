-- search_schools
-- arg1: String search parameters
SELECT
    name,
    code_departement,
    city_name,
    similarity (name_search, lower(unaccent ($1))) AS score
FROM
    french_schools
WHERE
    name_search % lower(unaccent ($1))
ORDER BY
    SCORE DESC
LIMIT 10;


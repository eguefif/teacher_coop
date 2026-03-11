-- search_schools
-- arg1: String search parameters
SELECT
    name,
    school_type,
    city_name,
    similarity (name_search, lower(unaccent ('Gilbert de'))) AS score
FROM
    french_schools
WHERE
    name_search % lower(unaccent ('Gilbert de'))
ORDER BY
    SCORE DESC
LIMIT 10;


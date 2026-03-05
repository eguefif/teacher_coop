-- Get user by id
SELECT
    *
FROM
    users
WHERE
    id = $1;


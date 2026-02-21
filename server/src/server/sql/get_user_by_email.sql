-- get user by email
SELECT
    *
FROM
    users
WHERE
    email = $1;


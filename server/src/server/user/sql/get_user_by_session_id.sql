SELECT
    sessions.expiration_at,
    users.id,
    users.full_name,
    users.email,
    users.user_type
FROM
    sessions
    INNER JOIN users ON users.id = sessions.user_id
WHERE
    sessions.id = $1;


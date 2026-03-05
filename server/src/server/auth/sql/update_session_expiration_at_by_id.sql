UPDATE
    sessions
SET
    expiration_at = $1
WHERE
    id = $2;


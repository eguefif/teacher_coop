INSERT INTO sessions (user_id, expiration_at)
    VALUES ($1, $2)
RETURNING
    *;


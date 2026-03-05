INSERT INTO files (filename, filepath, user_id)
    VALUES ($1, $2, $3)
RETURNING
    *;


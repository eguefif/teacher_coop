-- create user
INSERT INTO users (full_name, email, password)
    VALUES ($1, $2, $3)
RETURNING
    *;


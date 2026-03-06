-- create user
-- $1: full_name
-- $2: email
-- $3: password
INSERT INTO users (full_name, email, password)
    VALUES ($1, $2, $3)
RETURNING
    *;


-- create user
-- $1: full_name
-- $2: email
-- $3: password
-- $4: school_id
INSERT INTO users (full_name, email, password, school_id)
    VALUES ($1, $2, $3, $4)
RETURNING
    *;


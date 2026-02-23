--- migration:up
CREATE TABLE users (
    id bigserial PRIMARY KEY,
    full_name text NOT NULL,
    email text NOT NULL,
    password TEXT NOT NULL
);

--- migration:down
DROP TABLE users;

--- migration:end

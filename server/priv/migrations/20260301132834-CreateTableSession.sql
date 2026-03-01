--- migration:up
CREATE TABLE sessions (
    id uuid DEFAULT uuidv7 () PRIMARY KEY,
    user_id bigint NOT NULL,
    created_at timestamp NOT NULL DEFAULT NOW(),
    expiration_at timestamp NOT NULL
);

--- migration:down
DROP TABLE sessions;

--- migration:end

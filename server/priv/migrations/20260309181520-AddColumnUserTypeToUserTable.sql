--- migration:up
CREATE TYPE pg_user_type AS ENUM (
    'admin',
    'member'
);

ALTER TABLE users
    ADD user_type pg_user_type NOT NULL DEFAULT 'member';

--- migration:down
ALTER TABLE users
    DROP COLUMN user_type;

DROP TYPE pg_user_type;

--- migration:end

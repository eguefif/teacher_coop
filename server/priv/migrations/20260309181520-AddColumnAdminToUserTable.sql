--- migration:up
CREATE TYPE user_type AS ENUM (
    'admin',
    'user'
);

ALTER TABLE users
    ADD TYPE user_type NOT NULL DEFAULT 'user';

--- migration:down
ALTER TABLE users
    DROP COLUMN user_type;

DROP TYPE user_type;

--- migration:end


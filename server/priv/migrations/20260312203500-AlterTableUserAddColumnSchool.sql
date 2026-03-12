--- migration:up
ALTER TABLE users
    ADD COLUMN school_id text CONSTRAINT fk_french_schools REFERENCES french_schools (id) ON DELETE SET NULL;

--- migration:down
ALTER TABLE users
    DROP COLUMN school_id;

--- migration:end


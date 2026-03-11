--- migration:up
-- The following function is a wrapper around unaccent.
-- This is required to create a new column as PG except an IMMUTABLE marker to guarantee
-- deterministic generation
CREATE OR REPLACE FUNCTION f_unaccent (text)
    RETURNS text
    AS $$
    SELECT
        public.unaccent ('public.unaccent', $1);
$$
LANGUAGE sql
IMMUTABLE PARALLEL SAFE STRICT;

ALTER TABLE french_schools
    ADD COLUMN name_search text GENERATED ALWAYS AS (lower(f_unaccent (name))) STORED;

CREATE INDEX idx_on_french_schools_name_search ON french_schools USING gin (name_search gin_trgm_ops);

--- migration:down
ALTER TABLE french_schools
    DROP COLUMN IF EXISTS name_search;

--- migration:end


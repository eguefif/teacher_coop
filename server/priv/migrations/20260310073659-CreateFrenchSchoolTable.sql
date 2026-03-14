--- migration:up
-- The following function is a wrapper around unaccent.
-- This is required to create a new column as PG except an IMMUTABLE marker to guarantee
-- deterministic generation
CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE OR REPLACE FUNCTION f_unaccent (text)
    RETURNS text
    AS $$
    SELECT
        public.unaccent ('public.unaccent', $1);
$$
LANGUAGE sql
IMMUTABLE PARALLEL SAFE STRICT;

CREATE TYPE school_type AS ENUM (
    'elementary',
    'kindergarten',
    'elem_kinder',
    'middleschool',
    'general',
    'technology',
    'professionnal',
    'gen_tech', -- general and technology
    'gen_tech_pro', -- general, technology and professional
    'tech_pro',
    'no_type'
);

-- French school are categorize according to poverty
CREATE TYPE rep_type AS ENUM (
    'none',
    'rep',
    'rep+'
);

CREATE TABLE french_schools (
    id text PRIMARY KEY NOT NULL, -- Identifiant de l'etablissement in dataset
    name text NOT NULL,
    school_type school_type NOT NULL DEFAULT 'no_type',
    public boolean NOT NULL DEFAULT TRUE,
    postal_code text NOT NULL,
    city_name text NOT NULL,
    code_departement text NOT NULL,
    code_region text NOT NULL,
    rep rep_type NOT NULL DEFAULT 'none',
    search text GENERATED ALWAYS AS (lower(f_unaccent (name || ' ' || city_name))) STORED
);

CREATE INDEX idx_on_french_schools_search ON french_schools USING gin (search gin_trgm_ops);

--- migration:down
DROP TABLE french_schools;

DROP EXTENSION IF EXISTS pg_trgm;

DROP EXTENSION IF EXISTS unaccent;

DROP TYPE school_type;

DROP FUNCTION IF EXISTS f_unnacent;

DROP TYPE rep_type;

DROP INDEX ids_on_french_schools_search;

--- migration:end

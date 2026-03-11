--- migration:up
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
    rep rep_type NOT NULL DEFAULT 'none'
);

--- migration:down
DROP TABLE french_schools;

DROP INDEX french_schools_id_name_adresse_1;

DROP TYPE school_type;

DROP TYPE rep_type;

--- migration:end

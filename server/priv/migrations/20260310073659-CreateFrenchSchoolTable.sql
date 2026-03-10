--- migration:up
CREATE TYPE school_type AS ENUM (
    'elementary',
    'kindergarden',
    'elem_kinder',
    'middleschool',
    'general',
    'technology',
    'professional',
    'gen_tech', -- general and technology
    'gen_tech_pro', -- general, technology and professional
    'tech_pro',
    'no_type'
);

-- French school are categorize according to poverty
CREATE TYPE rep_type AS ENUM (
    'none',
    'REP',
    'REP+'
);

CREATE TABLE french_schools (
    name text NOT NULL,
    school_type school_type NOT NULL DEFAULT 'no_type',
    public boolean NOT NULL DEFAULT TRUE,
    postal_code smallint NOT NULL,
    city_name text NOT NULL,
    code_region smallint NOT NULL,
    rep rep_type NOT NULL DEFAULT 'none'
);

--- migration:down
DROP TABLE french_schools;

DROP TYPE school_type;

DROP TYPE rep_type;

--- migration:end

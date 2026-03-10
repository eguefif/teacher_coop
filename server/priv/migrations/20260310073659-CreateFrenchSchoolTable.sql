--- migration:up
CREATE TYPE school_type AS ENUM (
    'primary',
    'middleschool',
    'highschool',
    'secondary',
    'no_type'
);

CREATE TYPE primary_school_type AS ENUM (
    'elementary',
    'kindergarden',
    'both',
    'no_type'
);

CREATE TYPE french_highschool_type AS ENUM (
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
    primary_school_type primary_school_type NOT NULL DEFAULT 'no_type',
    highschool_type french_highschool_type NOT NULL DEFAULT 'no_type',
    rep rep_type NOT NULL DEFAULT 'none'
);

--- migration:down
DROP TABLE french_schools;

DROP TYPE school_type;

DROP TYPE primary_school_type;

DROP TYPE french_highschool_type;

DROP TYPE rep_type;

--- migration:end


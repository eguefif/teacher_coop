--- migration:up
CREATE TYPE job_status AS ENUM (
    'pending',
    'processing',
    'done'
);

CREATE TABLE file_ingestions_jobs (
    id bigserial PRIMARY KEY,
    filepath text NOT NULL,
    state job_status NOT NULL
);

--- migration:down
DROP TABLE file_ingestions_jobs;

DROP TYPE job_status;

--- migration:end


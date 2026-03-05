--- migration:up
CREATE TYPE job_status AS ENUM (
    'pending',
    'processing',
    'done'
);

CREATE TABLE file_ingestion_jobs (
    id bigserial PRIMARY KEY,
    filepath text NOT NULL,
    state job_status NOT NULL DEFAULT 'pending'
);

--- migration:down
DROP TABLE file_ingestion_jobs;

DROP TYPE job_status;

--- migration:end

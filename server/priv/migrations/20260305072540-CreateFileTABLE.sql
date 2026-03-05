--- migration:up
CREATE TABLE files (
    id bigserial PRIMARY KEY,
    filename text NOT NULL,
    filepath text NOT NULL,
    user_id bigint NOT NULL,
    file_ingestion_job_id bigint REFERENCES file_ingestion_jobs ON DELETE CASCADE
);

--- migration:down
DROP TABLE files;

--- migration:end

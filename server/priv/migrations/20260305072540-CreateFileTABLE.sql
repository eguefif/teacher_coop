--- migration:up
CREATE TABLE files (
    id bigserial PRIMARY KEY,
    filename text NOT NULL,
    filepath text NOT NULL,
    user_id bigint NOT NULL,
    file_ingestions_job_id bigint REFERENCES file_ingestions_jobs ON DELETE CASCADE
);

--- migration:down
DROP TABLE files;

--- migration:end


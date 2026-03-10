--- migration:up
CREATE TABLE school_ingestion_page_hashes (
    hash BIGINT NOT NULL
);

--- migration:down
DROP TABLE school_ingestion_page_hashes;

--- migration:end

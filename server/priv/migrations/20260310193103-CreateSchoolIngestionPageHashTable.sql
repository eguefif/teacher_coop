--- migration:up
CREATE TABLE school_ingestion_page_hashes (
    page int NOT NULL,
    hash INT NOT NULL
);

--- migration:down
DROP TABLE school_ingestion_page_hashes;

--- migration:end

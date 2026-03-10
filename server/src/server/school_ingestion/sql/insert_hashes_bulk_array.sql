-- insert_hashes_buld_array
-- $1: List(Int)
INSERT INTO school_ingestion_page_hashes
SELECT
    *
FROM
    unnest($1::int[], $2::int[]);


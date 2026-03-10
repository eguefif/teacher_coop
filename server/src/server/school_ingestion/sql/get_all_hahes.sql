SELECT
    *
FROM
    school_ingestion_page_hashes
WHERE
    hash = ANY ($1);


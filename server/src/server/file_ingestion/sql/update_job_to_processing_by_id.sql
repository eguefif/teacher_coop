UPDATE
    file_ingestion_jobs
SET
    state = 'processing'
WHERE
    id = $1;


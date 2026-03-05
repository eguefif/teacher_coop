UPDATE
    file_ingestion_jobs
SET
    state = 'done'
WHERE
    id = $1;


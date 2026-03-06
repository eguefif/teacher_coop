UPDATE
    files
SET
    file_ingestion_job_id = $1
WHERE
    id = $2
RETURNING
    *;


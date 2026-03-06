-- name: get_pending_ingestion_job()^
SELECT
    *
FROM
    file_ingestion_jobs
WHERE
    state = 'pending'
FOR UPDATE
    SKIP LOCKED
LIMIT 1;


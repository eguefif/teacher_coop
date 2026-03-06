-- name: update_job_to_processing(job_id)!
UPDATE
    file_ingestion_jobs
SET
    state = 'processing'
WHERE
    id = :job_id;


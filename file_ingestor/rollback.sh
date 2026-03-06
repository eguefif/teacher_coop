#!/bin/bash
PGPASSWORD=12345 psql -h 127.0.0.1 -U admin -d teacher_coop -c "update file_ingestion_jobs set state='pending';"
echo "select (*) from file_ingestion_jobs;"
PGPASSWORD=12345 psql -h 127.0.0.1 -U admin -d teacher_coop -c "select count(*) from file_ingestion_jobs;"

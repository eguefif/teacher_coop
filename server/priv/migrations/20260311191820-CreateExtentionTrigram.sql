--- migration:up
CREATE EXTENSION IF NOT EXISTS pg_trgm;

--- migration:down
DROP EXTENSION IF EXISTS pg_trgm;

--- migration:end


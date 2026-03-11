--- migration:up
CREATE EXTENSION IF NOT EXISTS unaccent;

--- migration:down
DROP EXTENSION IF EXISTS unaccent;

--- migration:end


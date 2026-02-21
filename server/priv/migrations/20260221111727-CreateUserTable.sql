--- migration:up
CREATE TABLE users(
  id UUID PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  password TEXT NOT NULL
);

--- migration:down

DROP TABLE users;

--- migration:end

# List all available commands
default:
    @just --list

# Start PostgreSQL via Docker Compose
db:
    docker compose up -d

# Run the Gleam backend server (port 3000)
server:
    cd server && gleam run

# Start the Gleam frontend dev server with hot-reload
client:
    cd client && gleam run -m lustre/dev start

# Source environment variables from init_env.sh
init-env:
    source ./init_env.sh

psql:
  psql -h 0.0.0.0 -p 5432 -Uadmin -d teacher_coop

db-build:
  cd server && gleam run -m db_build

g18n:
  cd shared && gleam run -m g18n/dev generate --nested

export DATABASE_URL := "postgres://admin:12345@127.0.0.1:5432/teacher_coop"
squirrel:
  cd server && gleam run -m squirrel
  just gen-doc

migrate:
  cd server && gleam run -m cigogne up

gen-doc:
  cd server && gleam docs build

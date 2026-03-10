set dotenv-load
# List all available commands
default:
    @just --list

# Start PostgreSQL via Docker Compose
db:
    docker compose up

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

squirrel:
  cd server && gleam run -m squirrel
  just gen-doc

migrate:
  cd server && gleam run -m cigogne up

migrate-down:
  cd server && gleam run -m cigogne down

migrate-all:
  cd server && gleam run -m cigogne all

gen-doc:
  cd server && gleam docs build

gleam-update:
  cd server && gleam update
  cd client && gleam update

schools:
  cd server && gleam run -m test_ingestion

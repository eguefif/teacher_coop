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

g18n:
  cd shared && gleam run -m g18n/dev generate --nested

squirrel:
  cd server && gleam run -m squirrel

migrate:
  cd server && gleam run -m cigogne up

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
env:
    source ./init_env.sh

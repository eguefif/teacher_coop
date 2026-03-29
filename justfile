db:
    docker compose up -d

server:
    mix phx.server

migrate:
    mix ecto.migrate

reset:
    mix ecto.reset

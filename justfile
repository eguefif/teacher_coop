all-recipes:
  @just --list

services:
    docker compose up

server:
    mix phx.server

migrate:
    mix ecto.migrate

reset:
    mix ecto.reset

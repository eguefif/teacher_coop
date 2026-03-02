# teacher_coop

A full-stack web application written entirely in [Gleam](https://gleam.run/), structured as a monorepo with three separate packages.

## TODO:
- [ ] Improve justfile and create a just db-build to reset app
- [X] Handle session in frontend Client
- [ ] Setup a staging environement to test on my homeserver
- [ ] End-to-End upload and search file
    - [ ] Add UI to upload file on user workspace
    - [ ] Add backend to download file and register it to PG for user
    - [ ] Rudimentary search with PG and download
- [ ] Improve search with Meilisearch
    - [ ] Install and Configure Meilisearch
    - [ ] Add logic to create job for ingestion when downloading file
    - [ ] Add a python service that will pull the DB for indexing job
    - [ ] Add logic for search frontend
    - [ ] Add logic for search backend

## Architecture

```
teacher_coop/
├── server/     # Backend HTTP server (Erlang/OTP, port 3000)
├── client/     # Frontend SPA (compiles to JavaScript)
└── shared/     # Shared types and serialization (used by both)
```

The `shared` package is referenced as a local path dependency in both `server/gleam.toml` and `client/gleam.toml`, ensuring types and JSON serialization stay in sync across the stack.

### Key tools

| Tool | Role | Docs |
|------|------|------|
| [Lustre](https://hexdocs.pm/lustre/) | Frontend MVU framework (Elm-like) | https://hexdocs.pm/lustre/ |
| [Wisp](https://hexdocs.pm/wisp/) | Backend HTTP routing/middleware | https://hexdocs.pm/wisp/ |
| [Cigogne](https://hexdocs.pm/cigogne/) | Database migration runner | https://hexdocs.pm/cigogne/ |
| [Squirrel](https://hexdocs.pm/squirrel/) | Type-safe SQL query codegen | https://hexdocs.pm/squirrel/ |

The client proxies `/api` requests to the backend (port 3000) via the Lustre dev server.

---

## Setup

### Prerequisites

- [Gleam](https://gleam.run/getting-started/installing/) >= 1.0
- [Erlang/OTP](https://www.erlang.org/downloads)
- [Node.js](https://nodejs.org/) (for the Lustre dev server)
- [Docker](https://docs.docker.com/get-docker/) and Docker Compose

### 1. Start the database

```sh
docker compose up -d
```

This starts a PostgreSQL 18 instance on port 5432 with:
- **User:** `admin`
- **Password:** `12345`
- **Database:** `teacher_coop`

### 2. Set the database environment variable

```sh
source init_env.sh
```

This exports `DATABASE_URL=postgres://admin:12345@127.0.0.1:5432/teacher_coop`.


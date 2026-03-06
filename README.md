# teacher_coop

A full-stack web application written entirely in [Gleam](https://gleam.run/), structured as a monorepo with three separate packages.

## TODO:
- [X] Improve justfile and create a just db-build to reset app
- [X] Handle session in frontend Client

### Session
- [ ] Fix problem where session is lost in the browser when server restart

### Frontend logic
- [x] Remove error input handling login form
- [x] Display message login error when failing to login
- [x] Use form on submit to allow for typing enter to submit: login and signup
- [ ] Improve signup form, validation input should reset when focus (hide red and error input)
- [ ] Should display that an email was sent in a toaster or message. It tells the user that their account was created
- [ ] Add email confirmation message (wait for stable version, for now confirm should be false and enable it manually via DB)
- [ ] Display message login to say that account is not activated

### File logic
- [ ] End-to-End upload and search file
    - [x] Add UI to upload file on user workspace
    - [x] Picking the file should not trigger sending the file: it should be triggered by the button
    - [x] Add backend to download file and register it to PG for user
- [ ] Implement search with Meilisearch
    - [ ] Install and Configure Meilisearch
    - [ ] Add logic to create job for ingestion when downloading file
    - [ ] Add a python service that will pull the DB for indexing job
    - [ ] Add logic for search frontend
    - [ ] Add logic for search backend
- [ ] Next iteration
    - [ ] Keep the file name from the file and fil a hidden input
    - [ ] Add metadata on the file: type of resource: sequence, exercices, support
    - [ ] Send as multipart

### Deployement
- [ ] Setup a staging environement to test on my homeserver
    -[X] Create Docker image
    -[ ] Use Coolify on my homeserver to monitor docker file
    -[ ] Setup Postgres
    -[ ] Handle migration
    -[ ] Make app deploy works
- [ ] What about a hash system that optimize storage. We only store one file but it can be pointed by multiple file row in the db

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


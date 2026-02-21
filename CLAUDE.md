# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`teacher_coop` is a full-stack web application written entirely in [Gleam](https://gleam.run/). It is structured as three separate Gleam projects:

- **`server/`** — Backend HTTP server (runs on Erlang/OTP, port 3000)
- **`client/`** — Frontend SPA (compiles to JavaScript)
- **`shared/`** — Shared types and serialization logic used by both client and server

The `shared` package is referenced as a local path dependency (`{ path = "../shared" }`) in both `server/gleam.toml` and `client/gleam.toml`.

## Commands

All commands must be run from within the relevant sub-project directory (`server/`, `client/`, or `shared/`).

### Server

```sh
cd server
gleam run       # Start the HTTP server on port 3000
gleam test      # Run tests
gleam build     # Build without running
```

### Client

```sh
cd client
gleam run -m lustre/dev start   # Start the Lustre dev server with hot-reload
gleam test                       # Run tests
gleam build --target javascript  # Build JS bundle
```

### Shared

```sh
cd shared
gleam test   # Run tests
gleam build  # Build
```

### Database

```sh
docker compose up -d   # Start PostgreSQL (postgres:18, port 5432, db: teacher_coop, user: admin, pass: 12345)
```

The server uses **squirrel** for type-safe SQL queries. After modifying `.sql` query files, run `gleam run -m squirrel` in `server/` to regenerate the query modules.

## Architecture

### Shared types (`shared/src/shared/user.gleam`)

Defines the `User` type and its JSON encoder/decoder. Both client and server import from this module to ensure serialization stays in sync.

### Server (`server/src/server.gleam`)

- Uses **Wisp** as the web framework and **Mist** as the HTTP server
- Routes are matched via pattern matching on `(method, path_segments)`
- Middleware is composed with `use <-` (Gleam's callback-chaining syntax)
- Currently has one endpoint: `POST /signup`
- **Squirrel** (`>= 4.6.0`) is included for generating type-safe PostgreSQL query functions from `.sql` files

### Client (`client/src/client.gleam`)

- Uses **Lustre** as the frontend framework (Elm-like MVU architecture)
- State is a single `Model` variant; messages are `Msg` variants
- HTTP calls are made via **rsvp** (a Lustre-friendly HTTP client)
- The client posts JSON to `http://127.0.0.1:3000/signup`
- Lustre dev tools provide hot-reload during development

### Key libraries

| Library | Used in | Purpose |
|---------|---------|---------|
| wisp | server | HTTP routing/middleware |
| mist | server | HTTP server (Erlang) |
| squirrel | server | Type-safe SQL codegen |
| pog | server | PostgreSQL driver |
| lustre | client | Frontend MVU framework |
| lustre_dev_tools | client | Dev server with hot-reload |
| rsvp | client | HTTP client for Lustre effects |
| gleam_json | shared, both | JSON encoding/decoding |

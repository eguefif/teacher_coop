# TeacherCoop

## Getting started

A `justfile` is provided for common tasks. Run `just` to list all available recipes.

1. Start the database (requires Docker):
   ```bash
   just services
   ```

2. Install dependencies, set up the database and assets:
   ```bash
   mix setup
   ```

3. Start the server:
   ```bash
   just server
   ```

4. Visit [http://localhost:4000](http://localhost:4000)

## Default user

Email: `admin@localhost.fr`

Login is done via a magic link. In development, emails are not sent — access the local mailbox at [http://localhost:4000/dev/mailbox](http://localhost:4000/dev/mailbox) to retrieve the link.


## Roadmap

### Document

- [ ] Meilisearch
    - [x] Add index
    - [x] Add logic that index new/update/delete document
    - [ ] Extract into background job to be sure we index things/ handle retry
- [ ] Create basic search

### Database
- [x] Add type: :utc_datetime to timestamps in migrations
- [x] Use elixir type and the right configuration: size default value is not always wanted
- [ ] Check for null constraints. We want to put as many constraints in the database as possible
- [ ] Update changeset: makes sure everything has the correct validations
- [ ] Add custom validations if necessary
- [ ] Add changeset if necessary
- [ ] Add  unique constraint on users: email
- [ ] Check if we need more unique constraint

### General

- [ ] Configure Elixir to use tzdata if Phoenix does not already do it
- [ ] Find the right color set
- [x] clean all useless context functions

### UI
- [ ] Create a list/grid documents index show: use in documents index and group documents index
- [ ] Remake UI and do localisatoin
    - [x] Search page
    - [ ] Login page
    - [ ] Register page
    - [ ] Welcome/confirm page

    - [ ] Workspace

    - [x] Documents list page
    - [ ] show document page
    - [ ] form document

    - [ ] Groups list page
    - [ ] show Group page
    - [ ] form Group

    - [x] Connections list page
    - [ ] settings

    - [ ] Autocomplete pop up
- [ ] Fix Autocomplete with + button for curriculum

- [ ] Responsiveness
    - [ ] Fix toggle dark/light component

### Authorization
- [ ] Find a pattern/architecture for authorization (see function `accessible_document`)
- [ ] Do TODO authorization and check

### Architecture

 - [x] Refactor current architecture by defining the domain correctly
 - [ ] Read about schema and context in Phoenix to make the right choice


### Fix
- [ ] Fix autocomplete document form curriculum: when usingkeyboard nav, selection with enter does not work


### Workspace Document
- [ ] Need a way to filter by tag

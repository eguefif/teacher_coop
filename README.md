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
    - [ ] Add index
    - [ ] Add script that index new document
- [ ] Create basic search

### General

- [ ] Find the right color set
- [ ] Remake UI
    - [ ] Main page
    - [ ] Workspace
    - [ ] Documents page
    - [ ] Groups page
    - [ ] Connections page
    - [ ] show Group page
    - [ ] show document page
    - [ ] form document
    - [ ] form Group
    - [ ] settings
- [ ] Responsiveness
    - [ ] Fix style selector
- [ ] Finish authorization and check
- [ ] clean all useless context functions

### Architecture

 - [ ] Refactor current architecture by defining the domain correctly
 - [ ] Read about schema and context in Phoenix to make the right choice


 ## Architecture

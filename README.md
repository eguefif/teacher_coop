# TeacherCoop

## Table of content

- [Setup](#setup)
- [Contexts](#contexts)
- [Repos](#repos)
- [Meilisearch](#meilisearch)
- [TODO](#todo)

## Setup

```bash
$ mix setup
$ docker compose up
$ mix phx.server
```

The website is available on `teachercoop:4000`

If you want to reset developement database and search engine: `mix reset`


## Contexts

### Library

Library is the context responsable for `Document` handling. A document is created by a teacher to gather files and metadata. It has three schemas:
* `Document`
* `File`
* `DocumentObjective` which is a join table for the many-to-many association with `Objective`

### Discovery

This context is responsible fo handling search. 
* Discovery: where we gather searches

This will handle two aspects of the search:
* Operations made by the user to find a document
* Tracking of search performance. We want the user to find what they need. Therefore, we want to evaluate the search and improve it.

## Repos

The project contains two repositories: `Repo`, `SearchRepo`. The former is the regular repo created with Phoenix to handle the Database. `SearchRepo` is a custom one that handles the SearchEngine.

[Repo Documention](TeacherCoop.Repo.html)
[SearchRepo Documention](TeacherCoop.SearchRepo.html)

### SearchRepo

This one will be peculiar. We want to improve search and test if improvement are better or not.
To do that, we might want to test different configuration on different instance.

## TODO
### Next
- [ ] Github actions are not working, make it work
- [ ] Have a complete CI/CD up and working with a DNS
    - [ ] Configure DB: user and password
    - [ ] Configure Meilisearch
    - [ ] Define secret
    - [ ] Create a GH that trigger something on the server and pull new repo
    - [ ] Create a domain name
    - [ ] Configure let's encrypt
    - [ ] Have an NGinx on the instance
    - [ ] Use a docker compose for now

### Testing

- [ ] Add test for SearchRepo: define behavior and use Mock
- [ ] Add test for render_async pages in Dashboard: define behavior and use Mock


### Search monitoring
- [ ] Words stat 
    - [x] Add zero results equivalent for words.
    - [x] Add a table for popular search terms
    - [ ] Add a new row in table for popular search terms: compared with the last month average
    - [ ] Add tests (check with --cover)
- [ ] Setup db to work on snapshot for dashboard
    - [ ] One materialized view for 7 days snapshot
    - [ ] One materialized for the current window: refresh twice a day
    - [ ] See if we need two for each: stats + words
    - [ ] Add stop words to the french configuration: it keep word like le la

- [ ] Dashboard
    - [x] Add a graph with evolution of zero result count
    - [x] Add a graph for successful searches
    - [x] Add a graph on how many searches
    - [ ] Add an indicator on search terms by click position average
    - [ ] Add an indicator on search terms
    - [ ] Add an indicator on search terms that returns zero results
    - [ ] Add an indicator on search retries
    - [ ] Add stat on average time before success, 10/90 decils
    - [ ] Show previous windows result close to the graph
    - [ ] Should be able to parameters how long is the comparison window

- [ ] Refactor search
    - [x] Add two tables: SearchSession, Search (see Obsidian)
    - [ ] Remove seearhsession table, just create a search_session id to manage to keep all searches in one session ( Before check search retries)

- [ ] Improve data gathering for search
    - [ ] Check user flow, what does it do.
    - [ ] Add test to be sure that we have the behavior we want.
    - [ ] Design a better architecture to be sure we get all we need
    - [ ] Add a cron task that mark search as timeout at some point when there is no
        activity

- [ ] Think of a way to create A/B testing
    - [ ] At the moment, index uid is hardcoded, take the result of get_index_test_a_b
        When no test, test the regular one, other else, random between regular and document_b
    - [ ] We might want to have two other documents indexes for each test.
    - [ ] AB testing could a a new table
    - [ ] User the ERT with a boolean: test_ab_running, if true, we use a random function to return either document index a or b.
    - [ ] The new test AB should allow the user to define configuration to use for test a an test b.
    - [ ] Test should have a default duration of 7 days.

### Search 
- [ ] Liveview search
    - [ ] Debounce update search
    - [ ] Add a suggestion search ? This would need a new index and store queries by popularity
    - [ ] When clicking on a document: return to search, result should still be here: keep alive
    - [ ] WHen clicking on a document: should be able to click download all and mark search as success

- [ ]Improve search result with accordeon
    - [x] Add filepaths in Meilisearch
    - [x] Add collapsable with objectives and list files
    - [x] Add preview for document
    - [x] Add download all button
	- [ ] Add facets: grade, school type, subject
	- [ ] Add an advanced search with facet preselections
- [ ] When Adding a new document, schedule a task that will create a compressed version of the document in PDF: use ghostscript
- [ ] Improve document: add the following as tags ?
	- [ ] Add a pedagogy style: standard, Montessori, Institutionnel, Freinet, alternative
	- [ ] Add a public target: country, city, REP/REP+, Autiste, (find more categories) there can be several of them


### SearchRepo behavior

 - [ ] We need to define a behavior for our SearchRepo
 - [ ] Mock that SearchRepo for test

### List
- [ ] Document creation: generate a document file in pdf that will be shiped with download all
- [ ] Finish reading chapter 5: p 156
- [ ] Search
    - [ ] Improve search result
    - [ ] Configure vector search
    - [ ] Optimize full text search
- [ ] Document ingestion
    - [x] Switch indexing in Oban
    - [x] Setup embedder
    - [ ] See to add a file, chunking and indexing with vector search (use text_chunker and pdf_extractor)
- [ ] Add user fullname
    - [x] Make the form works
    - [x] Add test for update
    - [x] Anytime a user changes their fullname, reindex all documents to update fullname
- [ ] Improve documents
    - [x] Be sure that delete works for every scenario: files and objectives.
        - [x] Delete files
        - [x] Delete join table for objectives
        - [x] Delete actual files
        - [x] Delete in Meilisearch
    - [x] Improve index page
    - [x] Improve show page
- [ ] Have a helper module that allows to retrieve information based on env: 
        (file_path for example, meilisearch server, postgres)

- [ ] Extract path to file in a global constant: see File and Document controller

- [ ] Subject color handling: should go in css as a variable and used like we use primary class
- [ ] We add a Meilisearch client in application that we don't use in SearchRepo: make it consistent.

- [ ] Add a field admin in user.

### Schola API

This API is consumed by the Schola app which is a local first program for teacher. This api needs
a way to get the school calendar each year with holidays and periode start and end day. It also needs
to get the curriculum.

- [ ] Add tests for new endpoint: year / curriculum
- [ ] Add a table school calendar that I can edit from the admin to replace hardcoded value.
- [ ] Think on how to handle curriculum update.
- [ ] Maybe add an endpoint that list all the curriculum years, if there is a new one, Schola will pull the new year. It can compares with its own database.

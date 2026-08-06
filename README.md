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


- [ ]Improve search result with accordeon
    - [x] Add filepaths in Meilisearch
    - [x] Add collapsable with objectives and list files
    - [x] Add preview for document
    - [ ] Add download all button
	- [ ] Add facets: grade, school type, subject
	- [ ] Add an advanced search with facet preselections
- [ ] Copy each files to create a lightweight preview files. Same name, different paths.
- [ ] Add a SearchSession table
	- [ ] session_id, user_id (nullable), query, created_at, num_results, downloaded_all_click, dwell_time, click_position (the index of the document clicked, if it's the 11nth, it means we have a ranking issue maybe), query_id (PK)

- [ ] Improve document: add the following as tags ?
	- [ ] Add a pedagogy style: standard, Montessori, Institutionnel, Freinet, alternative
	- [ ] Add a public target: country, city, REP/REP+, Autiste, (find more categories) there can be several of them


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
- [ ] When Adding a new document, schedule a task that will create a compressed version of the document in PDF: use ghostscript

- [ ] Subject color handling: should go in css as a variable and used like we use primary class
- [ ] We add a Meilisearch client in application that we don't use in SearchRepo: make it consistent.

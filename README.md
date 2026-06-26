# TeacherCoop

## Document

Document are the resource.

The context will be called: Library since it is shared by all teachers. They put resource in this
shared library.

This context will be split into two parts:
* the documents.ex for crude operation
* the search.ex for indexing/search with meilisearch

We have two context:
* Library: where we gather documents
* Discovery: where we gather searches

## TODO

 - [x] create a context/ressource for documents: Library Document documents
 - [x] Start with a minimal schema: document title + description
 - [x] Seed documents
 - [x] Simplify interface to its minimal: no theme choice, take the default one
    - [x] Minimal search box
    - [x] Document form and list for user
    - [ ] Search result
- [x] Meilisearch
    -[x] find a way to setup index
 - [ ] When first end-to-end over: add gettext

- [ ] Solve the Meilisearch test problems with indexing

 ## Test

 At the moment, we index as many document as the test run. It is a problem since we do not separate Meilisearch test and Meilisearch Dev. We need to find a solution for that.



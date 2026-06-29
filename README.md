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
- [ ] Finish reading chapter 5
- [ ] Improve research layout <-------------- WIP
- [ ] Improve documents
    - [ ] Add grade
    - [ ] Add tags
    - [ ] Add files


## Ways to improve search

I want to change the layout when a search is launched for the first time.
Maximum space should be dedicated to show answer and ways to improve search.

## Meilisearch

### Mix commands
There are two commands to manage Meilisearch:
* meilisearch.setup: init indexes
* meiliearch.reset_test: used to removes all documents from the tests indexes


### How to use

Meilisearch is ran in a process and started in [application.ex](./lib/teacher_coop/application.ex).
Interactions are abstracted away using the Repo pattern. All the logic is in the file: [search_engine_repo](./lib/teacher_coop/search_engine_repo.ex)
If we were to change the search engin, we would only have to modify these two files.


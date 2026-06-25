# TeacherCoop

## Document

Document are the resource.

The context will be called: Library since it is shared by all teachers. They put resource in this
shared library.

This context will be split into two parts:
* the documents.ex for crude operation
* the search.ex for indexing/search with meilisearch


## TODO

 - [x] create a context/ressource for documents: Library Document documents
 - [x] Start with a minimal schema: document title + description
 - [x] Seed documents
 - [ ] Simplify interface to its minimal: no theme choice, take the default one
    - [x] Minimal search box
    - [x] Document form and list for user
    - [ ] Search result
- [x] Meilisearch
    -[x] find a way to setup index
 - [ ] When first end-to-end over: add gettext
 - [ ] Index to meilisearch
 - [ ] Add search lj

  lib/teacher_coop/library.ex          # public API, delegates to sub-modules
  lib/teacher_coop/library/
    document.ex                        # Library.Document schema
    documents.ex                       # Library.Documents CRUD
    search.ex                          # Library.Search (Meilisearch)

  library.ex is just the public-facing module that calls into the sub-modules:

  defmodule TeacherCoop.Library do
    alias TeacherCoop.Library.{Documents, Search}

    defdelegate list_documents(scope), to: Documents
    defdelegate create_document(scope, attrs), to: Documents
    defdelegate search_documents(query), to: Search
  end

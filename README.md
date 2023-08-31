<!-- ABOUT THE PROJECT -->
## About The LeafNode Project

Text to Code document based API execution. Allows for external calls and human text execution


## TODO
- [x] Init the memory data to sync with persitence data on startup
- [x] Update prompt result format change -> fun(item1, item2)
- [x] Module for code generation and check whitelist
- [x] Execute document functions
- [x] Setup execution server
- [x] Execution server implementation
- [x] Finish up safe functions (WIP)
- [x] Remove the structs as later we will use a sql database
- [x] Controllers
    - [x] Documents
        - [x] GET, UPDATE, DELETE, CREATE
        - [x] Execute document
    - [x] Generate pseudo code that then gets executed
- [x] Calls to GenServers initially need to be dynamic timeout based on 5 * paragraph items
- [x] Remove use for to_atom dynamically as this grows and doesnt get cleaned up
- [x] Input selection from document paragraphs
- [ ] Allow to generate code per Text/Paragraph block (endpoint execute block)
- [ ] Stop execution once result is found for document selected execution
- [ ] Authorization and how the UI will tie up to the document and how you can create documents
- [ ] Dynamic tom generation cleanup and find another solution for

## Missing Important Pieces
- [x] Postman collection for the endpoints
- [ ] Postgres w/ Ecto setup (removal of DETs but keep ETS)
- [ ] Docker and containerizing the FE/BE and Database - folder structure all under one project
- [ ] UI (React)

## Postgres Migration
1. Generate a migration file for document creation

## Example document payload structure
```
    # document example
    # The general document itself and a result value that points to ID of text, text blocks come in a list for a document
    %{
        id: string;
        name: string;
        result: boolean | string;
        data: Text[];
    }

    # Text examples
    # Th is a definition of a text block, we use this to represent text and code from text
    %{
        id: string;
        pseudo_code: nil | string;
        data: nil | string;
    }
```


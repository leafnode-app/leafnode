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
- [x] Use document module for helper functions (move repo functions for documents to do crud operations)
- [x] Remove the servers for disk and memory and disk sync
- [x] create text blocks per document - API
- [ ] Deleting documents should remove associated texts
- [ ] Update document response to return list of texts by id (render by order)
- [ ] Function to get all texts (not lists by ids)
- [ ] Look into ways to move texts orders around?
- [ ] Execute document stored in repo
- [ ] Remove old tests/files that we dont need or old code
- [ ] Update all comments and generate ex_docs
- [ ] Update postman documentation
- [ ] Fix Deployment to registry auto
- [ ] Deploy to VM
- [ ] Logging, research what to use (grafana?) - We need to check the pricing of VMs and performance degregation
- [ ] Uptime kuma and status
- [ ] notification service - https://ntfy.sh/
- [ ] setup or use .env / .envrc to use in docker compose (remove dummy variables)
- [ ] auto deploy and job to auto pull and run on vm


## Missing Important Pieces
- [x] Postman collection for the endpoints
- [x] Postgres w/ Ecto setup (removal of DETs but keep ETS)
- [ ] Docker and containerizing the FE/BE and Database - folder structure all under one project
- [ ] UI (React)

## Postgres Migration
1. Generate a migration file for document creation


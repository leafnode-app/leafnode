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
- [x] Fix connecting app to postgres in conteiner (network issues)
- [x] Prod build on images for ENV
- [x] Separate env files (DB, APP, LOCAL) for development along with using in compose (APP, DB)
- [x] Deleting documents should remove associated texts - soft delete - flag is_deleted, we keep texts for training (need to mention to users)
- [x] Update document response to return list of texts by id (render by order)
- [x] setup or use .env / .envrc to use in docker compose (remove dummy variables)
- [x] multiple compose files for each env? https://danielwachtel.com/devops/dockerizing-a-phoenix-app-with-a-postgresql-database
- [x] Update postman documentation
- [x] Execute document stored in repo
- [ ] Table to have a copy of all texts regardless of deleted (we can then remove texts from text table and training data on the other)

- [ ] Remove old tests/files that we dont need or old code
- [ ] ETS to hash and store an executed document in memory for 1 day, if different input, change data, clear data otherwise
- [ ] Update all comments and generate ex_docs
- [ ] Tests before commit and test during branches
- [ ] Fix Deployment to registry auto (git workflow builds)
- [ ] Deploy to VM
- [ ] Auto Backup documents (off the VM or hosted machine if needed - maybe to .md?)
- [ ] validation to the text and document models and changesets
- [ ] Logging, research what to use (grafana?) - We need to check the pricing of VMs and performance degregation
- [ ] Uptime kuma and status
- [ ] notification service - https://ntfy.sh/
- [ ] auto deploy and job to auto pull and run on vm
- [ ] Some demos, examples (2-3)

## Functions to potentially add
- [ ] HTTP function (GET/POST)
    - HTTP headers might not be needed as this is a security concern and might require clever configs
- [ ] String operations (lowercase, uppercase)
- [ ] Some form of notification?

## Missing Important Pieces
- [x] Postman collection for the endpoints
- [x] Postgres w/ Ecto setup (removal of DETs but keep ETS)
- [x] Docker and containerizing the FE/BE and Database - folder structure all under one project
- [ ] UI / web app
- [ ] tally.so - doc design for creating docs
- [ ] https://cruip.com/3-examples-of-brilliant-vertical-timelines-with-tailwind-css/#:~:text=To%20create%20the%20vertical%20line,last%20element%20of%20the%20timeline.

## Next parts
- [ ] User table (env user first - root user, then later registering and usage)
- [ ] Access keys
- [ ] Masking Urls
- [ ] Configs/Constnts? - accessible through doc that you can save

We need to rethink about the tables and accociations of these

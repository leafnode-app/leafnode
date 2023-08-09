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
- [ ] Controllers
    - [ ] Documents
        - [ ] GET, UPDATE, DELETE, CREATE
        - [ ] Execute document
    - [ ] Paragraph/Text
        - [ ] Generate code (once we allow generate per block)
- [ ] Calls to GenServers initially need to be dynamic timeout based on 5 * paragraph items
- [ ] Change the paragraph struct to be named more generic %Text{} ?
- [ ] Allow to generate code per Text/Paragraph block
- [ ] Authorization and how the UI will tie up to the document and how you can create documents

## Later
- Access tokens generation for documents to execute
- UX/UX - https://www.blocknotejs.org/


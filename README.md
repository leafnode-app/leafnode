# Leafnode

## Overview
Document based API gateway that allows creation of documents and having the documuments be run through endpoints - With this you are able to express what you want to do with the payload coming in using text and AI has it expressed in code based on whitelist options the system understands as relevant and the data can be selected and mutated sequencually through blocks with the entire document output able to be selected as the result of the endpoint.

## Features
The project is currently not in active development but a side project that later will be the basis of another.

1. UI that allows creating documents
2. Create blocks in documents
3. Documents have unique identifiers that become routes to endpoints to POST to
4. Use AI LLM in order to infer custom psuedo code from text that generates pseudo code.
5. The ability to use basic mutation from block inputs referencing and taking results of other blocks
6. Setting document results to be the result of the call

## Installation and Usage
The application is built with Elixir(Phoenix) and Erlang. It is packaged with Docker but is able to be started without. This assumes you already have Elixir up and running on the current machine.

NOTE: You will need to have a postgres database up and running in order to have the documents and the psuedo code persisted along with the blocks the system creates. 

1. Copy the `app.example` and rename it to `app.env`, Copy the `db.example` and rename it to `db.env` 
2. Update the environment files with your relevant tokens and values
3. Look at the `docker-compose.yml` to make sure the values are good
4. Make sure docker-compose is running (assuming its installed)
5. Run the command `docker-compose build`
5. Run the command `docker-compose up -d`

At this point the application should be running

## Note
A lot of the app does not have tests as things are a POC but still working and managed to prove what an idea but and usable as a MVP.

If there is an issue running with the docker, I recommend having the postgres db start and stop the app, then run the app locally to point to the running container DB instance. This would mean changing the `app.env` and change the line `DB_HOSTNAME` to be `localhost` and `PORT` to be what ever the exposed port on the docker postgress instance.

# Leafnode

## Overview
Document based API gateway that allows creation of documents and having the documuments be run through endpoints - With this you are able to express what you want to do with the payload coming in using text and AI has it expressed in code based on whitelist options the system understands as relevant and the data can be selected and mutated sequencually through blocks with the entire document output able to be selected as the result of the endpoint.

## Installation and Usage
The application is built with Elixir(Phoenix) and Erlang. It is packaged with Docker but is able to be started without. This assumes you already have Elixir up and running on the current machine.

NOTE: You will need to have a postgres database up and running in order to have the documents and the psuedo code persisted along with the blocks the system creates. 

1. Copy the `app.example` and rename it to `app.env`, Copy the `db.example` and rename it to `db.env` 
2. Update the environment files with your relevant tokens and values
3. Look at the `docker-compose.yml` to make sure the values are good
4. Make sure docker-compose is running (assuming its installed)
5. Run the command `docker-compose build`
5. Run the command `docker-compose up -d`

## Note
A lot of the app does not have tests as things are a POC but still working and managed to prove what an idea but and usable as a MVP.

If there is an issue running with the docker, I recommend having the postgres db start and stop the app, then run the app locally to point to the running container DB instance. This would mean changing the `app.env` and change the line `DB_HOSTNAME` to be `localhost` and `PORT` to be what ever the exposed port on the docker postgress instance.

## Road to MVP (update with basic features list once mvp is released) 🎉

This is a list that is relevant from the date of 27th June 2024 serviing as a baseline for a todo list for a basic test release.

- [ ] GPT Input process setting
- [ ] Log updates to have references or IDs displayed
- [ ] Process setting (enable/disable - async/sync)
- [ ] Update output to caller to contain process result or reference to log id for data responses
- [ ] String interpolation for inputs (abilit to use dynamic inputs and hard coded values as part of data to send)
- [ ] Get Ngrok and project running on Raspberry PI for testing
- [ ] Basic website

This will be the main steps that will then require assessing and looking at case studies in order to show how it will work or usages and planning for other integrations and updating the current ones to use more rich text and markup for bodies of some of the integrations.
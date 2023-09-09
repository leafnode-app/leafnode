#!/bin/sh

# Note: /bin/sh must be at the top of the line,
# Alpine doesn't have bash so we need to use sh.
# Docker entrypoint script.
# Don't forget to give this file execution rights via `chmod +x entrypoint.sh`
# which I've added to the Dockerfile but you could do this manually instead.

#TODO: WE need to wait for postgres and not hadcode sleep
# Wait until Postgres is ready before running the next step.
# while ! pg_isready -q -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"
# do
#   echo "$(date) - waiting for database to start."
#   sleep 2
# done
echo "Sleep for around 10s then will start migrations"
sleep 10

# # Check if the database exists.
# db_exists=$(PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -Atqc "\\list $DB_NAME")

# # Create the database if it doesn't exist.
# # -z flag returns true if string is null.
# if [[ -z $db_exists ]]; then
#   echo "Database $DB_NAME does not exist. Creating..."
#   mix ecto.create
#   echo "Database $DB_NAME created."
# fi

# Runs migrations, will skip if migrations are up to date.
echo "Database $DB_NAME exists, running migrations..."
mix ecto.migrate
echo "Migrations finished."

# Start the server.
exec mix phx.server

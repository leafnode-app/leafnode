# docker exec -t CONTAINER pg_dump -U postgres -d leafnode_db > init_db_dump.sql

IO.puts("Enter the container ID, username, and DB name spaced in the following format: ")
IO.puts("CONTAINER_ID USERNAME DB_NAME SCHEMA_ONLY(y/n)")

user_input = IO.gets("> ")

case user_input do
  :eof ->
    IO.puts("No input received. Exiting...")

  _ ->
    input = String.trim(user_input)
    IO.puts("You entered: #{input}")

    [container_id, username, db_name, only_schema] = String.split(input, ~r/\s+/)

    only_schema = if only_schema == "y", do: true, else: false

    IO.puts("Container ID: #{container_id}")
    IO.puts("Username: #{username}")
    IO.puts("Database Name: #{db_name}")
    IO.puts("Schema Only?: #{only_schema}")

    command =
      if only_schema do
        "docker exec -t #{container_id} pg_dump --schema-only -U #{username} -d #{db_name} > init_db_dump.sql"
      else
        "docker exec -t #{container_id} pg_dump -U #{username} -d #{db_name} > init_db_dump.sql"
      end

    IO.puts("Running command: #{command}")

    # Execute the command
    {result, exit_code} = System.cmd("sh", ["-c", command])

    if exit_code == 0 do
      IO.puts("Database backup created successfully.")
    else
      IO.puts("Failed to create database backup.")
      IO.puts("Error: #{result}")
    end
end

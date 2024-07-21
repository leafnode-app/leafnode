# docker exec -t CONTAINER pg_dump -U postgres -d leafnode_db > init_db_dump.sql

IO.puts("Enter the container ID, username, and DB name spaced in the following format: ")
IO.puts("CONTAINER_ID USERNAME DB_NAME")

user_input = IO.gets("> ")

case user_input do
  :eof ->
    IO.puts("No input received. Exiting...")

  _ ->
    input = String.trim(user_input)
    IO.puts("You entered: #{input}")

    [container_id, username, db_name] = String.split(input, ~r/\s+/)

    IO.puts("Container ID: #{container_id}")
    IO.puts("Username: #{username}")
    IO.puts("Database Name: #{db_name}")

    command =
      "docker exec -t #{container_id} pg_dump -U #{username} -d #{db_name} > init_db_dump.sql"

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

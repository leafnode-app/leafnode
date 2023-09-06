# Use an official Elixir runtime as a parent image
FROM --platform=linux/arm64 arm64v8/elixir:latest

# Install inotify-tools
RUN apt-get update && apt-get install -y inotify-tools

# Set the working directory
WORKDIR /app

# Install dependencies
COPY mix.exs mix.lock ./
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

# Copy the current directory contents into the container
COPY . .

# Compile the project
# RUN mix compile
# RUN mix ecto.create
# RUN mix ecto.migrate
# RUN mix run priv/repo/seeds.exs
# CMD ["iex","-S", "mix", "phx.server"]
CMD ["/app/entrypoint.sh"]
# Use an official Elixir runtime as a parent image
FROM --platform=linux/arm64 arm64v8/elixir:latest

# Install inotify-tools
RUN apt-get update && apt-get install -y inotify-tools

# Set environment to production
ENV MIX_ENV prod

# Set the working directory
WORKDIR /app

# Install dependencies
COPY mix.exs mix.lock ./
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

# Copy the current directory contents into the container
COPY . .

# Build Assets
RUN mix assets.setup
RUN mix assets.build
RUN mix assets.deploy

# Define the entrypoint script
CMD ["/app/entrypoint.sh"]

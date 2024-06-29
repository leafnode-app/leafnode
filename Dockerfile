FROM elixir:1.16 AS build

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    npm \
    nodejs \
    locales \
    inotify-tools && \
    locale-gen en_US.UTF-8

# Set environment variables
ENV MIX_ENV=prod \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ELIXIR_ERL_OPTIONS="+fnu"

# Set the working directory
WORKDIR /app

# Copy mix files and dependencies
ADD mix.exs mix.lock /app/

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx

# Copy application files
COPY config /app/config
COPY assets /app/assets
COPY lib /app/lib
COPY priv/repo /app/priv/repo

# Install Elixir dependencies
RUN mix deps.get
RUN mix deps.compile

# Compile assets
RUN mix assets.deploy

# Expose the port
EXPOSE 4000

# Start the Phoenix server
CMD ["mix", "phx.server"]

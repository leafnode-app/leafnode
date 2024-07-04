# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :leaf_node,
  ecto_repos: [LeafNode.Repo]

# Configures the endpoint
config :leaf_node, LeafNodeWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST")],
  render_errors: [
    formats: [html: LeafNodeWeb.ErrorHTML, json: LeafNodeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LeafNode.PubSub,
  live_view: [signing_salt: "3x3DKDeW"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :leaf_node, LeafNode.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# This is for accounts later but to help limit the server usage
config :leaf_node, :acc_access,
  free: %{
    log_limit: 5,
    rate_limit: 10,
    node_limit: 3
  },
  paid: %{
    log_limit: 10,
    rate_limit: 5,
    node_limit: 10
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

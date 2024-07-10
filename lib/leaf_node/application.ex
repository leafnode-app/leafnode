defmodule LeafNode.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LeafNodeWeb.Telemetry,
      # Start the Ecto repository
      LeafNode.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LeafNode.PubSub},
      # Start Finch
      {Finch, name: LeafNode.Finch},
      # Start the Endpoint (http/https)
      LeafNodeWeb.Endpoint,
      # Start the Cloak Vault
      LeafNode.Cloak.Vault
    ]

    # init the demo processes on startup
    bootstrap()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LeafNode.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LeafNodeWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @doc """
    The startup function that runs to setup the example processes
  """
  def bootstrap() do
    # TODO: Use this with setup or startup of the application
  end
end

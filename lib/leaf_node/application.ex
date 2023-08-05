defmodule LeafNode.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  # Constants
  @id "id"

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LeafNodeWeb.Telemetry,
      # Start the Ecto repository
      # ---- ECTO -----
      # LeafNode.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LeafNode.PubSub},
      # Start Finch
      {Finch, name: LeafNode.Finch},
      # Start the Endpoint (http/https)
      LeafNodeWeb.Endpoint,
      # Jobs and processes for data interaction
      {LeafNode.Servers.DataSyncServer, %{ interval: 20_000}},
      LeafNode.Servers.MemoryServer,
      LeafNode.Servers.DiskServer
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
    Add and initialize the dets tables the system uses for persistence
  """
  def init_dets_tables() do
    dir = System.get_env("APP_DATA")
    case is_nil(dir) do
      true -> IO.inspect("Make sure to setup the env variable APP_DATA path")
      _ ->
        LeafNode.Core.Dets.get_system_tables()
        |> Enum.each(fn {_key, table} ->
          if !File.dir?(dir) do
            File.mkdir_p(dir)
          end

          file_path = String.to_charlist("#{dir}/#{table}.dets")
          LeafNode.Core.Dets.open_table(table, [{ :file, file_path }, { :type, :set }, {:auto_save, 30_000}])
          table
        end)
    end
  end

  @doc """
    Add and initialize files into memory (ETS)
  """
  def init_ets_tables() do
    %{ "documents" => documents } = LeafNode.Core.Ets.get_system_tables()
    if LeafNode.Core.Ets.table_exists?(documents) == false do
      LeafNode.Core.Ets.create_table(documents, [:set, :named_table, :public])
    end
  end

  @doc """
    The startup function that runs to setup the example processes
  """
  def bootstrap() do
    # init the dets tables the system will use for storage
    init_dets_tables()
    # init the ets tables, use this if you need add things in memeory on startup to RAM
    init_ets_tables()
  end
end

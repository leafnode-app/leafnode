defmodule LeafNode.Servers.DiskServer do
  @moduledoc """
    THis server will be called by the client that needs to interact with the persistence layer.
    This will be responsible for updating the data in memory
  """
  use GenServer
  require Logger
  alias LeafNode.Core.Documents, as: Documents

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
    Initialize the server
  """
  def init(state) do
    {:ok, state}
  end

  @doc """
    Get the hash of the current data in memory for the documents
  """
  def handle_call(:get_hash, _from, state) do
    {status, data} = LeafNode.Core.Dets.get_all(:documents)
    Logger.info("Server: LeafNode.Servers.DiskServer. Event: get_hash")
    resp = case status do
      :ok -> {:ok, :erlang.phash2(data)}
      _ -> {:error, data}
    end

    {:reply, resp, state}
  end

  #TODO: Reading data needs to be done against the MemoryServer

  @doc """
    Create document & request update to memory too
  """
  def handle_call(:create_document, _from, state) do
    Logger.info("Server: LeafNode.Servers.DiskServer. Event: create_document")
    { status, resp, document } = Documents.create_document(%{}, :documents, true)

    # success create we update memory
    if status === :ok do
      GenServer.call(LeafNode.Servers.MemoryServer, {:create_document, document})
    end

    {:reply, :ok, state}
  end

  @doc """
    Update document & request update to memory too
  """
  def handle_call(:update_document, _from, state) do
    Logger.info("Server: LeafNode.Servers.DiskServer. Event: update_document")
    {:reply, :ok, state}
  end

  @doc """
    Delete document & request update to memory too
  """
  def handle_call(:delete_document, _from, state) do
    Logger.info("Server: LeafNode.Servers.DiskServer. Event: delete_document")
    {:reply, :ok, state}
  end
end

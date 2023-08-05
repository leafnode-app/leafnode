defmodule LeafNode.Servers.MemoryServer do
  @moduledoc """
    This process manages the requests to update the data in memory.
    This will be called by the client if they want to read data and will be called
    by other processes that want to update or sync the memory data
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
    {status, data} = LeafNode.Core.Ets.get_all(:documents)
    Logger.info("Server: LeafNode.Servers.MemoryServer. Event: get_hash")
    resp = case status do
      :ok -> {:ok, :erlang.phash2(data)}
      _ -> {:error, data}
    end

    {:reply, resp, state}
  end

  @doc """
    Add to memory
  """
  def handle_call({:create_document, data}, _from, state) do
    LeafNode.Core.Ets.insert(:documents, data.id, data)
    Logger.info("Server: LeafNode.Servers.MemoryServer. Event: create_document")
    {:reply, :ok, state}
  end

  @doc """
    Remove from memory
  """
  def handle_call({:delete_document, id}, _from, state) do
    LeafNode.Core.Ets.delete_by_key(:documents, id)
    Logger.info("Server: LeafNode.Servers.MemoryServer. Event: delete_document")
    {:reply, :ok, state}
  end

  @doc """
    Update in memory
  """
  def handle_call({:update_document, data}, _from, state) do
    # we need to remove the old data first with ETS
    if LeafNode.Core.Ets.delete_by_key(:documents, data.id) do
      # inset the new updated version of the key that was removd
      LeafNode.Core.Ets.insert(:documents, data.id, data)
    end
    Logger.info("Server: LeafNode.Servers.MemoryServer. Event: update_document")
    {:reply, :ok, state}
  end

  @doc """
    Fetch from memory
  """
  def handle_call({:get_document, id}, _from, state) do
    {status, data} = LeafNode.Core.Ets.get_by_key(:documents, id)
    case status do
      :ok ->
        Logger.info("Server: LeafNode.Servers.MemoryServer. Event: get_document")
        {:reply, data, state}
      _ ->
        {:reply, data, state}
    end
  end
end

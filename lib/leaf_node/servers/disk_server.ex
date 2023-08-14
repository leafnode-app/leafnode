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
    Get the hash of the current data in memory for ALL the documents
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

  @doc """
    Create document & request update to memory too
  """
  def handle_call(:create_document, _from, state) do
    Logger.info("Server: LeafNode.Servers.DiskServer. Event: create_document")
    { status, resp, document } = Documents.create_document(%{}, :documents, true)

    # success create we update memory
    if status === :ok do
      GenServer.call(LeafNode.Servers.MemoryServer, {:create_document, document})
      {:reply, {status, document}, state}
    else
      {:reply, {status, resp}, state}
    end
  end

  @doc """
    Update document & request update to memory too
  """
  def handle_call({:update_document, id, document}, _from, state) do
    Logger.info("Server: LeafNode.Servers.DiskServer. Event: update_document")

    # TODO: we could rely on the client to generate per pargraph but for v1 we do it on any save
    {status, stored_doc} = GenServer.call(LeafNode.Servers.MemoryServer, {:get_document, id})
    updated_doc = if status === :ok do
      if has_document_data_changed(document, stored_doc) do
        generate_pseudo_code(document)
      else
        IO.inspect(:normal)
        document
      end
    end

    {status, resp, document} = Documents.edit_document(id, updated_doc, :documents, true)

    if status === :ok do
      GenServer.call(LeafNode.Servers.MemoryServer, {:update_document, document})
      {:reply, {status, document}, state}
    else
      {:reply, {status, resp}, state}
    end
  end

  @doc """
    Delete document & request update to memory too
  """
  def handle_call({:delete_document, id}, _from, state) do
    Logger.info("Server: LeafNode.Servers.DiskServer. Event: delete_document")
    {status, resp} = Documents.delete_document(id, :documents)

    if status === :ok do
      GenServer.call(LeafNode.Servers.MemoryServer, {:delete_document, id})
    end
    {:reply, {status, resp}, state}
  end

  # private functions

  # Compare and has the paragraph data to check if the document paragraph data has changed
  defp has_document_data_changed(new_document, old_document) do
    if Map.get(new_document, "id") === Map.get(old_document, "id") do
      :erlang.phash2(new_document.data) !== :erlang.phash2(old_document.data)
    else
      false
    end
  end

  # Generate pseudo code and return document with code
  defp generate_pseudo_code(document) do
    # TODO: Look at how we can dynamically increase timeout based on paragraps.
    # TODO: This call counld be parallel but we want to keep order, so we might need to increase timeout based on paragraph length
    IO.inspect("document - start")
    IO.inspect(document)
    IO.inspect("document - end")
    data = Enum.map(document.data, fn item ->
      IO.inspect("item - start")
      IO.inspect(item)
      IO.inspect("item - end")
      Map.update!(item, "pseudo_code", fn _value ->
        { status, resp } = LeafNode.Core.Gpt.prompt(Map.get(item, "data"))
        IO.inspect("status, resp - start")
        IO.inspect(status)
        IO.inspect(resp)
        IO.inspect("status, resp - end")
        case status do
          :ok -> resp
          # TODO: Add fallback result funciton if timeout is reached and mabe a better response message?
          _ -> Logger.error("There was an error: #{resp}. Module: LeafNode.Servers.DiskServer. Function: generate_pseudo_code")
        end
      end)
    end)
    # add the new data to the document
    Map.put(document, :data, data)
  end
end

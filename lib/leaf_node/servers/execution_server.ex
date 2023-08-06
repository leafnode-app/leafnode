defmodule LeafNode.Servers.ExecutionServer do
  @moduledoc """
    The execution server that will be used to create instances when executing a document
  """
  use GenServer
  require Logger

  @doc """
    State the server with base argument data
  """
  def start_link(args \\ %{}) do
    # we dont give a constant name so we can run multiple instances of this
    GenServer.start_link(__MODULE__, args)
  end

  @doc """
    Initialize the state of the server
  """
  def init(state) do
    state
  end

  @doc """
    Here we listen for the execution of the document
  """
  def handle_call({:exeute, document_id}, _form, state) do
    {status, document} = LeafNode.Core.Ets.get_by_key(:documents, id)

    case status do
      :ok ->
        Logger.info("Here we start the execition logic")
        {_status, result} = start_execution(document)
        {:reply, result, state}
      _ ->
        {:reply, "There was an error executing the document", state}
    end
  end

  @doc """
    Return the state after the execution
  """
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @doc """
    Stop the current server instance
  """
  def handle_call(:stop, _from, state) do
    GenServer.stop(self, :normal)
    {:reply, :ok, state}
  end

  # Helper methods

  @doc """
    We need to go through the relevant document to execute the code and store result
  """
  defp start_execution(document) do
    #TODO: Start executing document paragraphs
    #TODO: Be mindful of the document result settings, break if referencing a paragraph func
    {:ok, document}
  end
end

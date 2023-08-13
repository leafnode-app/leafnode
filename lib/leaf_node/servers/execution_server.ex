defmodule LeafNode.Servers.ExecutionServer do
  @moduledoc """
    The execution server that will be used to create instances when executing a document
  """
  use GenServer
  require Logger
  alias LeafNode.Servers.ExecutionHistoryServer, as: ExecutionHistoryServer

  @doc """
    State the server with base argument data
  """
  def start_link(id) do
    # we dont give a constant name so we can run multiple instances of this
    GenServer.start_link(__MODULE__, %{}, name: String.to_atom("execution_process_" <> id))
  end

  @doc """
    Initialize the state of the server
  """
  def init(state) do
    {:ok, state}
  end

  @doc """
    Here we listen for the execution of the document
  """
  def handle_call({:execute, document_id, payload}, _form, state) do
    # start the agent server for this document -  make sure its started
    ExecutionHistoryServer.start_link(document_id)

    # get the document in memory if it exists
    {status, document} = LeafNode.Core.Ets.get_by_key(:documents, document_id)
    case status do
      :ok ->
        Logger.info("Here we start the execition logic")
        {status, result} = start_execution(document)
        # Stop the history server instance here
        GenServer.stop(String.to_atom("history_" <> document_id), :normal)
        {:stop, :normal, {status, result}, state}
      _ ->
        # Stop the history server instance here
        GenServer.stop(String.to_atom("history_" <> document_id), :normal)
        {:stop, :normal, {:error, "There was an error executing the document"}, state}
    end
    #TODO: Do we need to stop the agent server? It is linked so exepct it to die out once this does
  end

  @doc """
    We need to go through the relevant document to execute the code and store result
  """
  defp start_execution(document) do
    # Flush the execution history before updating the data
    GenServer.call(String.to_atom("history_" <> document.id), :flush_history)
    # get the functions - and attempt excute
    Enum.each(document.data, fn paragraph ->
      paragraph_id = Map.get(paragraph, "id")
      pseudo_code = Map.get(paragraph, "pseudo_code")
      LeafNode.Core.Code.execute(pseudo_code, document.id, paragraph_id)
    end)

    {:ok, %{
      "document" => document,
      "results" => GenServer.call(String.to_atom("history_" <> document.id), :get_history)
    }}
  end
end

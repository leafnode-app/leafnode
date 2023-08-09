defmodule LeafNode.Servers.ExecutionServer do
  @moduledoc """
    The execution server that will be used to create instances when executing a document
  """
  use GenServer
  require Logger
  alias LeafNode.Agents.ExecutionHistoryAgent, as: ExecutionHistoryAgent

  @doc """
    State the server with base argument data
  """
  def start_link(args \\ %{}) do
    # we dont give a constant name so we can run multiple instances of this
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
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
  def handle_call({:execute, document_id}, _form, state) do
    # start the agent server for this document -  make sure its started
    Task.async(fn ->
      ExecutionHistoryAgent.start_link(document_id)
    end)

    # get the document in memory if it exists
    {status, document} = LeafNode.Core.Ets.get_by_key(:documents, document_id)
    case status do
      :ok ->
        Logger.info("Here we start the execition logic")
        {_status, result} = start_execution(document)
        {:stop, :normal, result, state}
      _ ->
        {:stop, :normal, "There was an error executing the document", state}
    end

    #TODO: Do we need to stop the agent server? It is linked so exepct it to die out once this does
  end

  @doc """
    We need to go through the relevant document to execute the code and store result
  """
  defp start_execution(document) do
    # get the functions - and attempt excute
    Enum.each(document.data, fn paragraph ->
      LeafNode.Core.Code.execute(paragraph.pseudo_code, document.id, paragraph.id)
    end)

    # We need to return the history?
    {:ok, %{
      "document" => document,
      "results" => ExecutionHistoryAgent.get_all(document.id)
    }}
  end
end

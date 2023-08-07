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
    {status, document} = LeafNode.Core.Ets.get_by_key(:documents, document_id)
    case status do
      :ok ->
        Logger.info("Here we start the execition logic")
        {_status, result} = start_execution(document)
        {:stop, :normal, result, state}
      _ ->
        {:stop, :normal, "There was an error executing the document", state}
    end
  end

  # Helper methods

  @doc """
    We need to go through the relevant document to execute the code and store result
  """
  defp start_execution(document) do
    # get the functions
    accumulated_data = Enum.reduce(document.data, %{}, fn paragraph, accumulated_data ->
      result = evaluate_pseudocode(paragraph.pseudo_code, accumulated_data)
      Map.put(accumulated_data, paragraph.id, result)
    end)

    IO.inspect(accumulated_data)
    {:ok, document}
  end

  @doc """
    We evaluate the psuedo code and the result can be returned of that code
  """
  defp evaluate_pseudocode(code, accumulated_data) do
    { status, eval_result } = LeafNode.Core.Code.execute(code, accumulated_data)

    case status do
      :ok ->
        {:ok, eval_result}
      _ ->
        {:ok, "Error evaluating pseudo code: #{code}"}
    end
  end
end

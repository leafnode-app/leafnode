defmodule LeafNode.Servers.ExecutionServer do
  @moduledoc """
    The execution server that will be used to create instances when executing a node
  """
  use GenServer
  require Logger
  alias LeafNode.Core.Log

  @error_execution "There was an error executing the node"
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
    Here we store the input to the execution payload instance so we can reference later
  """
  def handle_call(:get_input, _from, state) do
    {:reply, Map.get(state, "input", %{}), state}
  end

  @doc """
    Here we listen for the execution of the node
  """
  def handle_call({:execute, node_id, payload}, _form, state) do
    # get the node
    {status, node} = LeafNode.Core.Node.get_node(node_id)

    if node.enabled do
      # check node fetch data
      case status do
        :ok ->
          {status, result} = start_execution(node, payload)
          {:stop, :normal, {status, result}, state}
        _ ->
          {:stop, :normal, {:error, @error_execution}, state}
        end
      else
        {:stop, :normal, {:error, @error_execution}, state}
    end
  end

  @doc """
    Executing the node itself
  """
  defp start_execution(node, payload) do
    # LeafNode.Core.Code.execute(pseudo_code, node.id, text.id, payload)
    # TODO: Add the logic for the node execution in general

    # Here we need to set the logs - random for now
    if (node.should_log) do
      Log.create_log(node.id, payload, payload, Enum.random([true, false]))
    end

    # We just send the payload back for now - this needs to be based off the execution of the node
    {:ok, payload}
  end
end

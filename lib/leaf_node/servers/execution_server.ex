defmodule LeafNode.Servers.ExecutionServer do
  @moduledoc """
    The execution server that will be used to create instances when executing a node
  """
  use GenServer
  require Logger

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
    {status, node} = LeafNode.Repo.Node.get_node(node_id)
    if node.enabled do
      # check node fetch data
      case status do
        :ok ->
          {:stop, :normal, execute(node, payload), state}
        _ ->
          {:stop, :normal, {:error, @error_execution}, state}
      end
    else
      {:stop, :normal, {:error, @error_execution}, state}
    end
  end

  # The execution of the node expression against the payload
  defp execute(node, payload) do
    case execute_integration(node) do
      {:ok, data} ->
        # We add okay response for the logs to run in the backgorund
        LeafNode.Servers.TriggerInputProcess.query_ai(payload, data)
      _ ->
        {:error, "There was an error executing the integration"}
    end
  end

  # Here we do the integration if the node has and the relevant result and conditions are met
  defp execute_integration(%{ integration_settings: settings } = node) do
    LeafNode.Servers.TriggerIntegration.integration_action(settings["type"], node)
end
end

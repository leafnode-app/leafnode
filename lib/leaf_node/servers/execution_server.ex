defmodule LeafNode.Servers.ExecutionServer do
  @moduledoc """
    The execution server that will be used to create instances when executing a node
  """
  use GenServer
  require Logger
  alias LeafNode.Repo.Expression

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
    {status, node} = LeafNode.Repo.Node.get_node(node_id)

    if node.enabled do
      # check node fetch data
      case status do
        :ok ->
          {status, result} = start_execution(node, payload)
          # TODO: change this so its better, we can return the AI processed data

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
    {status, resp} = Expression.get_expression_by_node(node.id)

    case status do
      :ok ->
        execute(node, payload, resp)

      _ ->
        # failed to execute node
        error_result = "Missing node expression"

        LeafNode.log_result(
          node,
          payload,
          LeafNode.Utils.Helpers.http_resp(404, false, error_result),
          false
        )

        {:error, error_result}
    end
  end

  # The execution of the node expression against the payload
  # TODO: clean up
  defp execute(node, payload, expression) do
    {_, result} = LeafNode.Core.Code.execute(payload, expression)
    {input_process_status, %{ async: async,  enabled: process_enabled} = input_process} = LeafNode.Repo.InputProcess.get_input_process_by_node(node.id)
    LeafNode.log_result(node, payload, LeafNode.Utils.Helpers.http_resp(200, true, result), result)

    base_resp = %{
      cond: result,
    }

    data = if result do
      if async do
        # TODO: do we want to wait? we just let it run when it can
        Task.start(fn ->
          processed_data = if process_enabled do
            process_input(node, payload, input_process, input_process_status)
          else
            %{}
          end
          execute_integration(node, processed_data)
        end)

        base_resp
      else
        processed_data = if process_enabled do
          process_input(node, payload, input_process, input_process_status)
        else
          %{}
        end

        Task.start(fn ->
          execute_integration(node, processed_data)
        end)
        %{
          cond: result,
          input_process_resp: processed_data["input_process_resp"]
        }
      end
    else
      base_resp
    end


    # Always return the result, the other work will run when it can
    {:ok, data}
  end

  # Here we do the integration if the node has and the relevant result and conditions are met
  defp execute_integration(node, payload) do
      LeafNode.Servers.TriggerIntegration.integration_action(node.integration_settings["type"], node, payload)
  end

  # Process the input with input processed data
  defp process_input(node, payload, input_process_data, input_process_status) do
    # TODO: here we do checks if the user is doing processing for the input
      {_status, processed_resp} =
        LeafNode.Servers.TriggerInputProcess.query_ai(input_process_status, payload, input_process_data, node)

      # We do a copy and join to payload if the user enabled AI so we can have the user select from the data
      # TODO: this can or needs to change in future
      Map.put(payload, "input_process_resp", processed_resp)
  end
end

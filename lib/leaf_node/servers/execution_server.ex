defmodule LeafNode.Servers.ExecutionServer do
  @moduledoc """
    The execution server that will be used to create instances when executing a node
  """
  use GenServer
  require Logger
  alias LeafNode.Repo.Log
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

        log_result(
          node,
          payload,
          LeafNode.Utils.Helpers.http_resp(404, false, error_result),
          false
        )

        {:error, error_result}
    end
  end

  # The execution of the node expression against the payload
  defp execute(node, payload, expression) do
    {_, result} = LeafNode.Core.Code.execute(payload, expression)
    log_result(node, payload, LeafNode.Utils.Helpers.http_resp(200, true, result), result)

    # TODO: do we want to wait? we just let it run when it can
    Task.start(fn ->
      execute_integration(node, payload, result)
    end)

    # Always return the result, the other work will run when it can
    {:ok, result}
  end

  # Attempt to log the node input and persist
  defp log_result(node, input, result, status) do
    if node.should_log do
      Log.create_log(node.id, input, result, status)
    end
  end

  # Here we do the integration if the node has and the relevant result and conditions are met
  defp execute_integration(node, node_payload, node_result) do
    if (node_result) do
      integration_type(node.integration_settings["type"], node)
      # here we check the type and do something to try and execute
      log_result(node, node_payload, LeafNode.Utils.Helpers.http_resp(200, true, node_result), node_result)
    else
      # TODO: this needs to be from the result of the exeuction
      error_result = "Failed to execute integration"
      log_result(node, node_payload, LeafNode.Utils.Helpers.http_resp(404, false, error_result), node_result)
    end
  end

  # This is the call to execute the types
  defp integration_type(type, %{user_id: user_id} = node) when type === "google_sheet_write" do
    %{
      "input" => input,
      "range_end" => range_end,
      "range_start" => range_start,
      "spreadsheet_id" => id,
      "tab" => tab
    } = node.integration_settings

    # TODO: do a refresh token check here

    token_details = LeafNode.Repo.OAuthToken.get_token(user_id, type)
    IO.inspect(token_details)
    # call the function here
    LeafNode.Integrations.Google.Sheets.write_to_sheet(
      token_details.access_token,
      id,
      range_start <> ":" <> range_end,
      [String.split(input, ",")]
    )
  end

  defp integration_type(_), do: raise("Unsupported Integration")
end

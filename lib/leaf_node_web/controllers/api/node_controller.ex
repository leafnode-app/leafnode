defmodule LeafNodeWeb.Api.NodeController do
  @moduledoc """
    Controller that interfaces with the clients request and all the helpers around the processes
  """
  use LeafNodeWeb, :controller

  import Plug.Conn
  require Logger
  alias LeafNode.Utils.Helpers, as: Helpers

 @doc """
    Execute node
  """
  def execute_node(conn, params) do
    id = Map.get(params, "id")
    payload = Map.drop(params, ["id"])

    # Start the server if not already running
    LeafNode.Servers.ExecutionServer.start_link(id)

    {status, resp} =
      GenServer.call(String.to_atom("execution_process_" <> id), {:execute, id, payload})

    case status do
      :ok -> return(conn, 200, Helpers.http_resp(200, true, resp))
      _ -> return(conn, 404, Helpers.http_resp(404, false, resp))
    end
  end

@doc """
    Execute node - verbose - we return logs around each of the text blocks that ran
  """
  def execute_document_verbose(conn, params) do
    id = Map.get(params, "id")
    payload = Map.drop(params, ["id"])
    # Start the server if not already running
    LeafNode.Servers.ExecutionServer.start_link(id)

    {status, %{ "node" => node, "results" => paragraph_execution_results}} =
      GenServer.call(String.to_atom("execution_process_" <> id), {:execute, id, payload})

    document_result = Map.get(node, :result)

    # TODO: We can look at the an optional run with logs returned - we dont otherwise and rely on node result
    result = %{
      "document_result" => check_boolean_result(
        Map.get(paragraph_execution_results, document_result, document_result)
      ),
      "paragraph_results" => paragraph_execution_results
    }

    case status do
      :ok -> return(conn, 200, Helpers.http_resp(200, true, result))
      _ -> return(conn, 404, Helpers.http_resp(404, false, %{}))
    end
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end

  # here we check if the value can be a boolean, we then change the type to the correct boolean one
  defp check_boolean_result(value) do
    case value do
      "true" -> true
      "false" -> false
      _ -> value
    end
  end
end

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

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end
end

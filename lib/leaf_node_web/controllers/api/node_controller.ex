defmodule LeafNodeWeb.Api.NodeController do
  @moduledoc """
    Controller that interfaces with the clients request and all the helpers around the processes
  """
  use LeafNodeWeb, :controller

  import Plug.Conn
  require Logger

 @doc """
    Execute node
  """
  def execute_node(req, params) do
    id = Map.get(params, "user_id") |> Integer.to_string()
    payload = Map.drop(params, ["id"])

    # Start the server if not already running
    # GenServer takes the id of the user, so that we queue user requests by their id
    LeafNode.Servers.ExecutionServer.start_link(id)

    # Here we create a payload that contains the question and params sent with the request
    payload = %{
      req: req,
      params: payload
    }

    {status, resp} =
      GenServer.call(String.to_atom("execution_process_" <> id), {:execute, req["node"], payload})

    case status do
      :ok -> %{ status: 200, data: resp }
      _ -> %{ status: 500, data: resp }
    end
  end
end

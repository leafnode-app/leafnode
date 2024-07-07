defmodule LeafNodeWeb.ExtensionApi.NodeController do
  @moduledoc """
    Controller that interfaces with the clients request and all the helpers around the processes
  """
  use LeafNodeWeb, :controller

  import Plug.Conn
  require Logger
  alias LeafNode.Utils.Helpers, as: Helpers

  @doc """
    Get the list of nodes for the given user
  """
  def get_nodes(%{private: private} = conn, _) do
    {status, nodes} = LeafNode.Repo.Node.list_nodes(private.user_id)
    # create node metadata only of enabled nodes
    case status do
      :ok ->
        simple_nodes = Enum.map(nodes, fn n ->
          if n.enabled do
            %{
              title: n.title,
              desc: n.description,
              id: n.id,
              access_key: n.access_key
            }
          end
        end)

        IO.inspect(simple_nodes, label: "NODES LIST")
        return(conn, 200, Helpers.http_resp(200, true, %{
          data: simple_nodes
        }))
      _ ->
        return(conn, 200, Helpers.http_resp(200, true, %{
          data: []
        }))
    end
  end

  @doc """
    Execute node
    TODO: This can move or potentially we can reuse the one in the general controller?
  """
  def execute_node(conn, params) do
    LeafNodeWeb.Api.NodeController.execute_node(conn, params)
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end
end

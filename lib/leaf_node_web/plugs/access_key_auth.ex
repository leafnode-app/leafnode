defmodule LeafNodeWeb.Plugs.AccessKeyAuth do
  @moduledoc """
    Plug that will be used to check the connection against the access keys for a node to execute
  """
  import Plug.Conn
  alias LeafNode.Repo.Node

  @doc """
    Initialize the conneciton with opts to be passed when passing the connection through the plug
  """
  def init(opts), do: opts

  @doc """
    The call function that gets called after init setup. We check the header and the access token
  """
  def call(conn, _opts) do
    %{"id" => id} = Map.get(conn, :params, nil)

    case get_req_header(conn, "x-api-key") do
      [token] ->
        token =
          String.split(token, " ")
          |> List.last()

        check_process_access(conn, token, id)
      _ ->
        return(conn, 401,
          %{ "message" => "Unable to execute node. Contact node admin",
            "success" => false,
            "data" => %{}
          }
        )
    end
  end

  # we check the passed token validity
  defp check_process_access(conn, token, id) do
    {status, node} = Node.get_node(id)
    case status do
      :ok ->
        node_access_token = Map.get(node, :access_key)
        if node_access_token === token do
          # we can assign a flag around the connection to know its accessible
          conn
        else
          return( conn, 401,
            %{ "message" =>
                "Unauthorized access.",
              "success" => false,
              "data" => %{}
            }
          )
        end
      _ ->
        return( conn, 401,
          %{ "message" => "Unauthorized access.",
            "success" => false,
            "data" => %{}
          }
        )
    end
  end

  # JSON returned response helper method for the controller functions
  defp return(conn, status, data) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Jason.encode!(data))
  end
end

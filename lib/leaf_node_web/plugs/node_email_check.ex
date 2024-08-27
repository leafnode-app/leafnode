defmodule LeafNodeWeb.Plugs.NodeEmailCheck do
  @moduledoc """
    Check if the email is relevant on the system
  """
  import Plug.Conn

  @doc """
    Initialize the conneciton with opts to be passed when passing the connection through the plug
  """
  def init(opts), do: opts

  @doc """
    The call function that gets called after init setup. We check the header and the access token
  """
  def call(%Plug.Conn{params: params} = conn, _opts) do
    # get node to execute
    node_email = params["To"]
    node = LeafNode.Repo.get_by(LeafNode.Schemas.Node, email_hash: node_email)
    case node do
      nil ->
        conn
        |> send_resp(403, "Forbidden")
        |> halt()
      _ ->
        conn
        |> put_private(:node_id, node.id)
    end
  end
end

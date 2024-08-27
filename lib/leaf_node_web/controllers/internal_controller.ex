defmodule LeafNodeWeb.InternalController do
  @moduledoc """
    Controller connecting to the internal services
  """
  use LeafNodeWeb, :controller

  import Plug.Conn

  @doc """
    Trigger the node based on the email address
  """
  def trigger(conn, params) do
    payload = %{
      "id" => conn.private.node_id,
      "subject" => Map.get(params, "Subject"),
      "text_body" => Map.get(params, "TextBody"),
      "from_name" => Map.get(params, "FromName"),
      "from" => Map.get(params, "From"),
      "to" => Map.get(params, "To"),
      "cc" => Map.get(params, "Cc"),
      "bcc" => Map.get(params, "Bcc"),
    }

    LeafNodeWeb.Api.NodeController.execute_node(conn, payload)
  end

end

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
      # The message will only be the last sent message in the conversation or thread
      "text_body" => clean_conversation_data(Map.get(params, "TextBody")),
      "from_name" => Map.get(params, "FromName"),
      "from" => Map.get(params, "From"),
      "to" => Map.get(params, "To"),
      "cc" => Map.get(params, "Cc"),
      "bcc" => Map.get(params, "Bcc"),
    }

    #  We need to make sure we get the body in the correct format and pass that along
    LeafNodeWeb.Api.NodeController.execute_node(conn, payload)

    # TODO: take the result and pass it back to get it sent off as a response with the context
  end

  # clean up the conversation for a consistent format
  # We only care about latest message and not the whole conversation
  defp clean_conversation_data(string) do
    string |> String.split("\n") |> Enum.at(0)
  end


end

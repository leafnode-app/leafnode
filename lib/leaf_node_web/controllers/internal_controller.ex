defmodule LeafNodeWeb.InternalController do
  @moduledoc """
    Controller connecting to the internal services
  """
  use LeafNodeWeb, :controller
  alias LeafNode.Integrations.OpenAi.Gpt

  import Plug.Conn

  @timeout 30_000
  @doc """
    Trigger the node based on the email address
  """
  def trigger(conn, params) do
    payload = %{
      "user_id" => conn.private.user_id,
      "subject" => Map.get(params, "Subject"),
      # The message will only be the last sent message in the conversation or thread
      "text_body" => clean_conversation_data(Map.get(params, "TextBody")),
      "from_name" => Map.get(params, "FromName"),
      "from" => Map.get(params, "From"),
      "to" => Map.get(params, "To"),
      "cc" => Map.get(params, "Cc"),
      "bcc" => Map.get(params, "Bcc"),
    }

    # NOTE: make sure no crashing and managing different responses
    {_status, resp} = try do
      Gpt.prompt(payload["text_body"], conn.private.user_id, :assistant)
    rescue
      _ ->
        {:error, %{ "message" => false}}
    end

    # manage handing the response
    handle_response(resp, payload)

    # Always return some response back to the caller
    conn |> send_resp(200, Jason.encode!(%{}))
  end

  # clean up the conversation for a consistent format
  # We only care about latest message and not the whole conversation
  defp clean_conversation_data(string) do
    string |> String.split("\n") |> Enum.at(0)
  end

  # handle the assistant response
  defp handle_response(%{ "message" => _message, "node" => _node_id } = ai_req, payload) do
    # Async start node task
    task = Task.async(fn ->
      LeafNodeWeb.Api.NodeController.execute_node(ai_req, payload)
    end)
    # wait for server response result
    resp = Task.await(task, @timeout)
    # We send a email back with the response?
    IO.inspect(resp, label: "PROCESS RESP")
  end
  defp handle_response(%{ "message" => false }, _) do
    # We do nothing? The assistant does nothing
  end
  defp handle_response(_, _) do
    # Something happened, we send a message to the user that there is a problem?
  end
end

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
      "in_reply_to" => get_message_id(params["Headers"]),
      "references" => get_message_id(params["Headers"]),
    }

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
  # TODO: Potentially limit the context here?
  defp clean_conversation_data(string) do
    # Unescape newlines
    unescaped_data = String.replace(string, "\\n", "\n")

    # Split the string into sections based on double newlines
    sections = String.split(unescaped_data, ~r/\n{2,}/)

    # Reduce the sections into a threaded format string
    Enum.reduce(sections, "", fn section, acc ->
      # Clean up leading/trailing whitespaces and join sections with a separator
      cleaned_section = String.trim(section)
      acc <> "\n\n" <> cleaned_section
    end)
  end

  # Generic response incase there is no node able to answer
  defp handle_response(%{ "message" => resp, "node" => nil }, payload) do
    LeafNode.Client.MsgServer.post("/email/send", Jason.encode!(mail_payload(payload, resp)))
  end
  # handle the assistant response
  defp handle_response(%{ "message" => _message, "node" => _node_id } = ai_req, payload) do
    # Async start node task
    task = Task.async(fn ->
      LeafNodeWeb.Api.NodeController.execute_node(ai_req, payload)
    end)
    # wait for server response result
    %{ data: data, status: _} = Task.await(task, @timeout)
    # We send a email back with the response?
    Task.start(fn ->
      LeafNode.Client.MsgServer.post("/email/send", Jason.encode!(mail_payload(payload, data["message"])))
    end)
  end
  defp handle_response(%{ "message" => resp }, payload) do
    LeafNode.Client.MsgServer.post("/email/send", Jason.encode!(mail_payload(payload, resp)))
  end

  # Get the message id value
  defp get_message_id(headers) do
    %{ "Name" => _, "Value" => value } = headers
      |> Enum.find(fn %{ "Name" => id, "Value" => _} -> id === "Message-ID"  end)

    # The message id to use as reference and in reply to
    value
  end

  # this will setup andse
  def mail_payload(payload, resp) do
    %{
      "from" => payload["to"],
      "subject" => payload["subject"],
      "text" => resp,
      "to" => payload["from"],
      "in_reply_to" => payload["in_reply_to"],
      "references" => payload["references"],
    }
  end
end

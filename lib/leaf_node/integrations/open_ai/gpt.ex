defmodule LeafNode.Integrations.OpenAi.Gpt do
  @moduledoc """
    Module for helper methods accessing Open AI interaction
  """
  require Logger
  @timeout 30_000

  @doc """
    Send through the payload and a string of process or what you want to process against the payload
  """
  def prompt(payload, process, :node) do
    if !is_nil(config(:token)) do
      body_payload = Map.put(
        model_settings(), "messages",
        [
          %{
            "role" => "system",
            "content" => query_node(payload, process)
          }
        ]
      )

      {status, resp} = HTTPoison.post(
        config(:completions_url),
        Jason.encode!(body_payload),
        [
          {"Content-type", "application/json"},
          {"Authorization", "Bearer #{config(:token)}"}
        ],
        recv_timeout: @timeout
      )
      case status do
        :ok -> handle_response(resp)
        :error -> {:error, "There was an error: #{resp}"}
      end
    else
      {:error, "There was an error getting the OPEN_AI key, check env variables"}
    end
  end

  def prompt(payload, user_id, :assistant) do
    if !is_nil(config(:token)) do
      body_payload = Map.put(
        model_settings(), "messages",
        [
          %{
            "role" => "system",
            "content" => query_assistant(payload, user_id)
          }
        ]
      )

      {status, resp} = HTTPoison.post(
        config(:completions_url),
        Jason.encode!(body_payload),
        [
          {"Content-type", "application/json"},
          {"Authorization", "Bearer #{config(:token)}"}
        ],
        recv_timeout: @timeout
      )
      case status do
        :ok -> handle_response(resp)
        :error -> {:error, "There was an error: #{resp}"}
      end
    else
      {:error, "There was an error getting the OPEN_AI key, check env variables"}
    end
  end

  # Handle the success reponse and its codes that came back from the HTTP post
  defp handle_response(resp) do
    case resp.status_code do
      200 ->
        resp = Jason.decode!(resp.body)
        {_status, data} = return_choice_by_index(resp, 0)
        {:ok, Jason.decode!(data)}
      _ ->
        {
          :error,
          "There was an error: #{Jason.decode!(resp.body)}"
        }
    end
  end

  # Take in a list of choiced from a response and return the index
  defp return_choice_by_index(choices, index) do
    {_tag, data} = Enum.at(choices, index)
    {:ok, Enum.at(data, 0) |> Map.get("message") |> Map.get("content")}
  end

  @doc """
    The prompt function that we can call to get teh prompt
  """
  defp query_node(payload, input_process) do
    "You are a system that processes data. You will receive an input payload and an input_process string. Use the input_process to process and respond based on the payload. Always return a string as a response.

    Important notes:
    - If the request in the input_process makes no sense or cannot be fulfilled, return a short 20 word message of why.
    - Return only the answer; avoid verbose context. Provide clear, direct responses.
    - Always attempt to generate a meaningful response using the payload as context for the input_process.
    - Instead of saying you cant do something, if you cant - always suggest an improvement to the passed data or if there is no imporovement, return false.

    Final notes:
    Return a json response in the format of:
    {
      data: [THE PROCESSED RESPONSE BASED ON THE PAYLOAD AND INPUT PROCESS],
      improvement: [THE SUGGESTED IMPROVEMENT IF THERE IS OR NILL]
    }

    Ensure:
    - The response is useful and directly related to the payload.
    - The response should be specific and actionable if a template is requested, without any placeholders.

    payload: #{Jason.encode!(payload)}
    input_process: #{input_process}"
  end

  @doc """
    Query the assistant to get the nodes and the question if applicable
  """
  defp query_assistant(payload, user_id) do
    """
    Provide valid JSON output.
    You will be given a thread of data representing a conversation or a series of messages.
    Your task is to determine whether the conversation includes a question specifically directed at you.
    Your question needs to be generated as if someone asked and you are going to ask on behalf of them, it shouldnt be vague but based
    off the conversations, a question you can ask the node.

    When you identify a question, compare it against the list of nodes provided below. Each node has a title and description to help you decide which node is most relevant to the question.

    - If a relevant node is found, formulate a question that could be asked of that node to obtain an answer.
    - If there are nodes available but none are relevant, return 'false'.
    - If no nodes are available or you cannot determine the relevance, politely say that you cannot help and suggest that nodes need to be added.

    Input Data (Conversation): #{Jason.encode!(payload)}

    Nodes List: #{Jason.encode!(get_nodes(user_id))}

    Your response should follow one of these formats:

    **Failure (no relevant node found):**
    {
      "message": false
    }

    **Success (relevant node found):**
    {
      "message": "[your formulated question based on the input data]",
      "node": "[the relevant node ID]"
    }

    Please follow these instructions carefully, and avoid making assumptions beyond the provided data. Make sure to onle return
    node information if there is a node that could work based on the title and description, IT IS FALSE OTHERWISE!
    """
  end


  # Get the model settings for the prompt
  defp model_settings() do
    %{
      "temperature" => 0,
      "model" => config(:model),
      "response_format" => %{ "type" => "json_object"}
    }
  end

  # Get user nodes
  defp get_nodes(user_id) do
    case LeafNode.Repo.Node.list_nodes(user_id) do
      {:ok, nodes} ->
        Enum.filter(nodes, fn node -> node.enabled end)
        |> Enum.map(fn node -> %{
          title: node.title,
          description: node.description,
          id: node.id
        } end)
      {:error, _err} ->
        Logger.error("No nodes to add")
        "No thing found"
    end
  end

  # config to get based off the application name
  def config(), do: Application.get_env(:leaf_node, :open_ai)
  def config(key, default \\ nil), do: Keyword.get(config(), key, default)
end

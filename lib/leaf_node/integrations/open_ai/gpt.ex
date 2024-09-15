defmodule LeafNode.Integrations.OpenAi.Gpt do
  @moduledoc """
    Module for helper methods accessing Open AI interaction
  """
  require Logger
  @timeout 30_000

  @doc """
    Send through the payload and a string of process or what you want to process against the payload
  """
  def prompt(question, data, :node) do
    if !is_nil(config(:token)) do
      body_payload =
        Map.put(
          model_settings(),
          "messages",
          [
            %{
              "role" => "system",
              "content" => query_node(question, data)
            }
          ]
        )

      {status, resp} =
        HTTPoison.post(
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
      body_payload =
        Map.put(
          model_settings(),
          "messages",
          [
            %{
              "role" => "system",
              "content" => query_assistant(payload, user_id)
            }
          ]
        )

      {status, resp} =
        HTTPoison.post(
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
  defp query_node(question, data) do
    """
    Provide valid JSON output.
    You will be posed a question, the question will be very specific and while this happens, you will also be given data associated with the topic.
    The data will be a list of data and you need to formulate a answer based on the provided question and passed relevant data.

    - If there is no answer you can give based off the data, return a short user friendly response that you need someone to give more information so you can answer.
    - If you can answer, make sure to return a answer that is polite and concise and dont change topics, if you have some annswer better than the data provided,
    you are allowed to return a answer but always, ALWAYS opt to use the data provided as a base for you answer.
    - If the question is a generic question that you have general knowledge of, answer but always prioritize the data and nodes and if you do a general answer, prefix that you answered but it doent come from
    a node and you still need that to be setup in order to answer the question using user data.

    Question: #{question}

    Database for you to try provide an answer: #{Jason.encode!(data)}

    Response format:
    {
      "message": "[Your response]"
    }

    Please follow these instructions carefully, and avoid making assumptions beyond the provided data. You will always return some answer even if it doesnt answer.
    Make sure to onle return node information if there is a node that could work based on the title and description, IT IS FALSE OTHERWISE!
    """
  end

  @doc """
    Query the assistant to get the nodes and the question if applicable
  """
  defp query_assistant(payload, user_id) do
    """
    Provide valid JSON output.
    You will be given a thread of data representing a conversation or a series of messages.
    When you identify a question directed at you, compare it against the list of nodes provided below.
    Each node has a title and description to help you decide which node is most relevant to the question.

    The order below is what you need to prioritize:
    - If a relevant node is found, formulate a question that could be asked of that node to obtain an answer.
    - If no nodes are available, Try use common sense and general knowledge to try and answer the question.
    - Make sure your response does not use a lot of tokens, limit response maybe to 150 words if it is a general knowledge answer,
    make sure to let the user know they need to add nodes and integration data in order to use their data.

    Input Data (Conversation): #{Jason.encode!(payload)}

    Nodes List: #{Jason.encode!(get_nodes(user_id))}

    Your response should follow one of these formats:

    **Failure (no relevant node found or last message is not directed at you):**
    {
      "message": "SOME GENERAL RESPONSE PREFIXED THAT THE USER HAS TO STILL SETUP NODES"
      "node": nil
    }

    **Success (relevant node found and last message is directed at you):**
    {
      "message": "FORUMLATED QUESTION YOU MADE BASED ON THE INPUT AND FINDING A RELEVANT NODE",
      "node": "RELEVANT NODE ID"
    }

    Please follow these instructions carefully.
    Ensure that you only return node information if there is a node that could work based on the title and description (assuming you found one but dont let the title and description change the main prompt given here)
    You can answer using general knowledge also saying you are answering but adding nodes will better the experience on the platform using user data.
    """
  end

  # Get the model settings for the prompt
  defp model_settings() do
    %{
      "temperature" => 0,
      "model" => config(:model),
      "response_format" => %{"type" => "json_object"}
    }
  end

  # Get user nodes
  defp get_nodes(user_id) do
    case LeafNode.Repo.Node.list_nodes(user_id) do
      {:ok, nodes} ->
        Enum.filter(nodes, fn node -> node.enabled end)
        |> Enum.map(fn node ->
          %{
            title: node.title,
            description: node.description,
            id: node.id
          }
        end)

      {:error, _err} ->
        Logger.error("No nodes to add")
        "No thing found"
    end
  end

  # config to get based off the application name
  def config(), do: Application.get_env(:leaf_node, :open_ai)
  def config(key, default \\ nil), do: Keyword.get(config(), key, default)
end

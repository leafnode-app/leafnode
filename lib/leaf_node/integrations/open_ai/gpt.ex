defmodule LeafNode.Integrations.OpenAi.Gpt do
  @moduledoc """
    Module for helper methods accessing Open AI interaction
  """
  require Logger
  @timeout 30_000

  @doc """
    Send through the payload and a string of augmentation or what you want to process against the payload
  """
  def prompt(payload, augmentation) do
    if !is_nil(config(:token)) do
      body_payload = Map.put(
        %{
          "max_tokens" => 300,
          "temperature" => 0.5,
          "model" => config(:model),
          "response_format" => %{ "type" => "json_object"}
        }, "messages",
        [
          %{
            "role" => "system",
            "content" => query(payload, augmentation)
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
        {:ok, data}
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
  def query(payload, augment) do
    "You are a system that processes data and returns a concise, useful string. You will receive an input payload and an augment string. Use the augment to process and respond based on the payload. Always return a string as a response.

    Important notes:
    - If the request in the augment makes no sense or cannot be fulfilled, return \"null\".
    - Return only the answer; avoid verbose context. Provide clear, direct responses.
    - Return plain text only, no rich text, markup, or placeholders like [Your Name].
    - Never exceed 200 tokens in your response.
    - Return a system error if the response would be \"null\" to the augment.
    - Always attempt to generate a meaningful response using the payload as context for the augment.

    Final notes:
    Return a JSON response in the format of:
    {
      data: [THE PROCESSED RESPONSE BASED ON THE PAYLOAD AND AUGMENT],
      error: [ANY SYSTEM ERRORS THAT OCCURRED, providing a layperson explanation for updating the augment or processing prompt],
      improvement: [A suggestion for improving the augment or processing prompt. If no suggestion is needed, return null]
    }

    Ensure:
    - The response is useful and directly related to the payload.
    - Avoid ending responses with placeholders like [Your Name].
    - The response should be specific and actionable if a template is requested, without any placeholders.

    payload: #{Jason.encode!(payload)}
    augment: #{augment}"
  end

  # config to get based off the application name
  def config(), do: Application.get_env(:leaf_node, :open_ai)
  def config(key, default \\ nil), do: Keyword.get(config(), key, default)
end

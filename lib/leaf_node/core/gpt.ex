defmodule LeafNode.Core.Gpt.Prompt do
  @moduledoc """
    The prompt module section that can host the data of the prompt itself

    Pricing:
    This will be using the base gpt-3.5-turbo model by default, this can be changed.

    Model: gpt-3.5-turbo
    Input: $0.0015 / 1k tokens - 1 token ($0.0000015)
    Output: $0.002 / 1K tokens - 1 token ($0.000002)

    Given how the system will work.

    Doc limit: 5
    Paragaph per doc: 10
    Paragraph limit: 80 characters
    Prompt: 242 tokens
    Potential Max tokens: 322 tokens

    Cost per paragraph (worst case of max tokens):

    Input: $0.000483 (prompt passed with token limit)
    Output $0.0002 (with the function output returned)

    Total per paragraph (max token): $0.000683
    Total per doc (max paragraphs): $0.00683
    Total (max documents paragraphs): $0.03415 (R0.6147) - Assuming the data doesnt change and maxed all doc/paragaph options

    Text will be hashed so we can check if we need to reprocess when saving the doc if it is needed
  """

  @doc """
    The prompt function that we can call to get teh prompt
  """
  def query(input) do
    "Given the function specifications and a paragraph of text, identify and return the first function call from the text in the format 'function(param1, param2, ...)'. If no function call is identified, return 'value(false)'.
    Functions can call other paragraphs' results using the ref() function, which references the ID of the paragraph whose result is being called. If the paragraph contains a comparison or question about numbers, interpret it using comparison functions. If it mentions returning a specific string value, use the 'value()' function with the string enclosed in double quotes (\"string\").

    Function specifications:

    @spec add(number, number) :: number
    @spec subtract(number, number) :: number
    @spec multiply(number, number) :: number
    @spec divide(number, number) :: number
    @spec value(boolean | string | number) :: boolean | string | number
    @spec ref(binary) :: term()
    @spec equals(term(), term()) :: boolean
    @spec not_equals(term(), term()) :: boolean
    @spec less_than(number, number) :: boolean
    @spec greater_than(number, number) :: boolean
    @spec input() :: map()

    Input paragraph: #{input}"
  end
end

defmodule LeafNode.Core.Gpt do
  @moduledoc """
    Module for helper methods accessing Open AI interaction
  """
  require Logger

  # API key
  @env "OPEN_AI"
  @api_key System.get_env(@env)
  @model System.get_env("OPEN_AI_MODEL")

  @url "https://api.openai.com/v1/chat/completions"
  # body
  @body %{
    "max_tokens" => 500,
    "temperature" => 0,
    "model" => @model
  }
  # header
  @headers [
    {"Content-type", "application/json"},
    {"Authorization", "Bearer " <> to_string(@api_key)}
  ]

  @timeout 20000

  @doc """
    The prompt sent to get the message
    NOTE: This module will have set the params to a manageable temp and potentially limit input
    See body
  """
  # TODO: Meta programming can be used here to generate the functions
  def prompt(msg) do
    prompt = LeafNode.Core.Gpt.Prompt.query(msg)
    # check the status - this is help make sure we dont execute test payloads
    Logger.info("Started AI workflow generation")
    if !is_nil(System.get_env(@env)) do
      body_payload = Map.put(@body, "messages",
        [
          %{
            "role" => "system",
            "content" => prompt
          }
        ]
      )

      {status, resp} = HTTPoison.post(@url, Jason.encode!(body_payload), @headers, recv_timeout: @timeout)
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
      400 ->
        {
          :error,
          "There was an error: #{Jason.decode!(resp.body)}"
        }
      200 ->
        resp = Jason.decode!(resp.body)
        {_status, data} = return_choice_by_index(resp, 0)
        {:ok, data}
      _ ->
        Logger.error("Error prompt", file: "gpt.ex", stacktrace: "fn -> handle_response | innput resp from fn -> prompt")
    end
  end

  # Take in a list of choiced from a response and return the index
  defp return_choice_by_index(choices, index) do
    {_tag, data} = Enum.at(choices, index)
    {:ok, Enum.at(data, 0) |> Map.get("message") |> Map.get("content")}
  end
end

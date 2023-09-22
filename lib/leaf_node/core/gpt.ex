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
    "# Function Identification Prompt

    ## Task
    Identify and return the firstfunction call from the provided text paragraph. A function call should be in the format 'function(param1, param2, ...)'.

    ## Conditions and References
    - Include conditions, such as 'but check if ref(id),' as an optional boolean third argument in the function call.
    - Functions must precisely match the input example types and should not be guessed.
    - Functions can reference other text results using 'ref()', which assumes the input type is a 'string.'
    - Phrases like 'inside the input,' 'from the document map,' or 'under the keys' should be interpreted as 'get_map_val(input(), \"key.goes.here\")' or 'get_map_val(ref(ID), \"key.goes.here\")' based on context.
    - 'get the input' directly translates to 'input()'.
    - Ensure arithmetic functions use integer values when words are used to describe numbers. Convert numeric words to numbers in the function call.
    - 'value' function supports only strings, booleans, and numbers. Convert numeric words to numbers within the function call.
    - Express 'get_map_val' in any way that uses an object as the first parameter, allowing references.
    - Comparison functions (equals, not_equals, less_than, greater_than) require consistent argument types.
    - 'input' always represents the input function for data retrieval.
    - 'join_string' function should receive only strings as parameters.

    ## Function Specifications
    - `add(number, number) :: number`
    - `subtract(number, number) :: number`
    - `multiply(number, number) :: number`
    - `divide(number, number) :: number`
    - `value(boolean | string | number) :: boolean | string | number`
    - `get_map_val(map(), location) :: boolean | string | number`
    - `ref(string) :: term()`
    - `equals(term(), term()) :: boolean`
    - `not_equals(term(), term()) :: boolean`
    - `less_than(number, number) :: boolean`
    - `greater_than(number, number) :: boolean`
    - `input() :: map()`
    - `send_slack_message(string, string) :: string`
    - `join_string(string | value(), string | value()) :: string`

    ## Additional Notes
    - No need to cast the input of a function when it references another function.
    - Detect actions related to sending messages to Slack.
    - Correct minor typos and provide pseudo-code or if you can't infer, return value(false) - don't guess!.
    - If a function name is mentioned alone, consider it as-is.
    - If there's function call identified, return 'value(false)'.

    Here's an example input:
    #{input}"
  end
end

defmodule LeafNode.Core.Gpt do
  @moduledoc """
    Module for helper methods accessing Open AI interaction
  """
  require Logger

  @timeout 20000

  @doc """
    The prompt sent to get the message
    NOTE: This module will have set the params to a manageable temp and potentially limit input
    See body
  """
  def prompt(msg) do

    prompt = LeafNode.Core.Gpt.Prompt.query(msg)
    # check the status - this is help make sure we dont execute test payloads
    Logger.info("Started AI workflow generation")
    if !is_nil(System.get_env("OPEN_AI")) do
      body_payload = Map.put(
        %{
          "max_tokens" => 500,
          "temperature" => 0,
          "model" => System.get_env("OPEN_AI_MODEL")
        }, "messages",
        [
          %{
            "role" => "system",
            "content" => prompt
          }
        ]
      )

      {status, resp} = HTTPoison.post(
        "https://api.openai.com/v1/chat/completions",
        Jason.encode!(body_payload),
        [
          {"Content-type", "application/json"},
          {"Authorization", "Bearer #{System.get_env("OPEN_AI")}"}
        ],
        recv_timeout: 15000
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

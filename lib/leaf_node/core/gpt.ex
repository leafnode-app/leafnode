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
    "Identify and return only the first function call from a given paragraph of text. The function call should be in the format 'function(param1, param2, [conditional])'. The '[conditional]' is an optional boolean parameter that controls the execution of the function. If no function call is identified, return 'value(false)'.

    Conditions and References:
    - If the paragraph mentions a condition to check, like 'but check if ref(id)', include that condition as a third, optional argument in the function call. The third argument is a boolean.
    - Functions can refer to other text results using the ref() function, which references the ID of the paragraph whose result is being called.
    - For retrieving values from a map, phrases like 'inside the input', 'from the document map', or 'under the keys' should be interpreted as 'get_map_val(input(), \"key.goes.here\", [conditional])' or 'get_map_val(ref(ID), \"key.goes.here\", [conditional])' depending on the context.
    - Phrases like 'get the input' should directly translate to 'input()'.
    - If a Ref is inferred, always make sure the value that is passed, is a \"string\" - never pass anything else as the input type needs to be a string to this function
    - The ref function can be expressed in ways like refernce, get, fetch from other block, other text so make sure this and anything else that describes trying to use data from another block of text will use the ref function keeping its types in mind being passed
    - with any of the mentioned arithmetic functions, use the int value of the number if a word variation was described regardless if part was using a int and the other wasnt
    - value function only supports the type string, boolean, number. Nothing else
    - the function get_map_val can be described in any way that expresses the use of a object, map, dictionary in any way along with the first paramater needing to be a object. This value can ref other values
    - comparison function, equals, not_equals, less_than, greater_than - These need to have the same type in the arguments that will be compared against
    - input is always the input function, make sure you look at any phrasing that results in getting input data, payload, document data, passed data etc. anything in any way that is similar to describing a payload input passed to a document or the system itself
    - join_string function needs to make sure it always passes strings to the params, nothing else, they will need to be converted otherwise. Keep any phrase around joining, concat, interpolating, or anything similar expressing joining words or strings together
    - if the input of a func is a reference to using another function or using another function that is here as an input, this does not need to have it casted to the input type - this system allows using functions together
    - Slack is a IM system, look for any word that describes sending a message to it in some way. Any action that seems to describe posting a message to slack
    - Make an educated guess if there is typo's, dont just fallback to false the user tried but had spelling errors
    - If at anypoint the persin just types the function name, use it as is as well

    Function Specifications:
    - @spec add(number, number) :: number
    - @spec subtract(number, number) :: number
    - @spec multiply(number, number) :: number
    - @spec divide(number, number) :: number
    - @spec value(boolean | string | number) :: boolean | string | number
    - @spec get_map_val(map(), location) :: boolean | string | number
    - @spec ref(string) :: term()
    - @spec equals(term(), term()) :: boolean
    - @spec not_equals(term(), term()) :: boolean
    - @spec less_than(number, number) :: boolean
    - @spec greater_than(number, number) :: boolean
    - @spec input() :: map()
    - @spec send_slack_message(string, string) :: string
    - @spec join_string(string, value()) :: string

    Input: #{input}"
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

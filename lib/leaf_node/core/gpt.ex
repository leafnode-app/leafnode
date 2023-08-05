defmodule LeafNode.Core.Gpt.Prompt do
  @moduledoc """
    The prompt module section that can host the data of the prompt itself
  """

  @doc """
  The prompt function that we can call to get teh prompt
  """
  def query(input) do
    "Given the function specifications and a paragraph of text, immediately return the first identified function call from the text in the format 'function:[parameters]'. If no function call is identified, return 'result:[false]'.

    Function specifications:

    @spec add(number, number) :: number
    @spec subtract(number, number) :: number
    @spec multiply(number, number) :: number
    @spec divide(number, number) :: number
    @spec value(boolean | string | number) :: boolean | string | number
    @spec ref(binary) :: term()
    @spec get_map_val(map, binary) :: term()
    @spec equals(term(), term()) :: boolean
    @spec not_equals(term(), term()) :: boolean
    @spec less_than(number, number) :: boolean
    @spec greater_than(number, number) :: boolean

    Input paragraph: <input_paragraph>"
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

  @url "https://api.openai.com/v1/completions"
  # body
  @body %{
    "max_tokens" => 128,
    "temperature" => 0.4,
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
      body_payload = Map.put(@body, "prompt", prompt)
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
    resp = Enum.at(data, 0)
    # TODO: we need to keep tabs on this to make sure the resp doesnt change
    {:ok, String.trim(resp["text"])}
  end
end

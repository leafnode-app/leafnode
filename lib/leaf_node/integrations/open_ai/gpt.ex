defmodule LeafNode.Integrations.OpenAi.Gpt do
  @moduledoc """
    Module for helper methods accessing Open AI interaction
  """
  require Logger
  @timeout 30_000

  # This is basic promp templates - add this to the db so we can add new ones later
  @templates %{
    "prompts" => [
      %{
        "id" => 1,
        "description" => "Validate the input and rate it out of 10. Provide a brief description. If the email is not intended for validation, respond politely explaining that your purpose is to validate content."
      },
      %{
        "id" => 2,
        "description" => "Summarize the content of this email in three sentences. If summarization isn't needed, respond with a friendly note explaining your purpose."
      },
      %{
        "id" => 3,
        "description" => "Extract any important dates mentioned in the email and list them. If no dates are found, state that none were identified."
      },
      %{
        "id" => 4,
        "description" => "Identify any action items in this email and list them clearly. If there are no action items, respond politely saying none are needed."
      },
      %{
        "id" => 5,
        "description" => "Translate the email content to Spanish. If the email is already in Spanish or another language, acknowledge and explain your translation service."
      },
      %{
        "id" => 6,
        "description" => "Identify and list any email addresses mentioned in the content. If none are found, note that no email addresses were detected."
      },
      %{
        "id" => 7,
        "description" => "Check the email for spelling and grammar errors. If the email is well-written, respond with a positive affirmation of its quality."
      },
      %{
        "id" => 8,
        "description" => "Categorize the content of this email as either 'Personal,' 'Work-related,' or 'Other.' If it doesn't fit these categories, kindly mention what categories you can process."
      },
      %{
        "id" => 9,
        "description" => "Extract any numerical data from this email and present it in a list. If there's no numerical data, note that none were found."
      },
      %{
        "id" => 10,
        "description" => "Summarize any financial information in the email. If there's no financial content, explain that you were looking for such information but found none."
      },
      %{
        "id" => 11,
        "description" => "Identify any questions in this email and list them separately. If there are no questions, respond with a friendly note that none were found."
      },
      %{
        "id" => 12,
        "description" => "Scan the email for any URLs and list them. If no URLs are found, mention that the content doesn't contain any links."
      },
      %{
        "id" => 13,
        "description" => "Classify the tone of the email as 'Formal,' 'Informal,' or 'Neutral.' If the tone doesn't fit, kindly mention the tone you detected."
      },
      %{
        "id" => 14,
        "description" => "Extract and list any addresses or locations mentioned in this email. If none are present, state that no locations were identified."
      },
      %{
        "id" => 15,
        "description" => "Identify any attachments in this email and describe them briefly. If there are no attachments, respond that the email is attachment-free."
      },
      %{
        "id" => 16,
        "description" => "Analyze the sentiment of the email (positive, neutral, or negative) and provide a brief explanation. If the sentiment is unclear, mention that your purpose is sentiment analysis."
      },
      %{
        "id" => 17,
        "description" => "Extract and summarize the main points from the email. If no clear points are found, respond with a note explaining that the email lacks key points."
      },
      %{
        "id" => 18,
        "description" => "Detect any potential spam or phishing content in the email. If the email appears safe, respond with an acknowledgment."
      },
      %{
        "id" => 19,
        "description" => "Identify any names mentioned in the email and list them. If no names are found, note that none were identified."
      },
      %{
        "id" => 20,
        "description" => "Convert the email content into a to-do list. If the content doesn't lend itself to a to-do list, explain that your purpose is task extraction."
      }
    ]
  }


  @doc """
    Send through the payload and a string of process or what you want to process against the payload
  """
  def prompt(payload, process) do
    if !is_nil(config(:token)) do
      body_payload = Map.put(
        %{
          "temperature" => 0.25,
          "model" => config(:model),
          "response_format" => %{ "type" => "json_object"}
        }, "messages",
        [
          %{
            "role" => "system",
            "content" => query(payload, process)
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
  def query(payload, input_process) do
    "You are a system that processes data. You will receive an input payload and an input_process string. Use the input_process to process and respond based on the payload. Always return a string as a response.

    Important notes:
    - If the request in the input_process makes no sense or cannot be fulfilled, return a short 20 word message of why.
    - Return only the answer; avoid verbose context. Provide clear, direct responses.
    - Always attempt to generate a meaningful response using the payload as context for the input_process.
    - Instead of saying you cant do something, if you cant - always suggest an improvement to the passed data or if there is no imporovement, return false.

    Final notes:
    Return a JSON response in the format of:
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

  # config to get based off the application name
  def config(), do: Application.get_env(:leaf_node, :open_ai)
  def config(key, default \\ nil), do: Keyword.get(config(), key, default)
end

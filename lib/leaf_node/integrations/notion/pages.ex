defmodule LeafNode.Integrations.Notion.Pages do
  @moduledoc """
    The Notion integrations and helper functions in order to interact with it
  """
  @notion_version "2021-05-13"

  @doc """
    The metadata to get information on how to render the fields in order to interact with the interaction
  """
  # TODO: This could be changed to use json schema - we can then get this info based on selected type and render it
  def input_info() do
    [
      {"page_id", "Page Id", "text", "The Notion page ID. Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.some_id]]."},
      {"content", "Content", "text", "Content for the Notion page. Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.text_content]]."}
    ]
  end

  @spec append_content(any(), any(), any()) :: {:error, any()} | {:ok, any()}
  @doc """
    Append values to notion page - this is a basic block, it can be changed later
  """
  def append_content(page_id, token, content) do
    url = "https://api.notion.com/v1/blocks/#{page_id}/children"

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Notion-Version", @notion_version},
      {"Content-Type", "application/json"}
    ]

    body = %{
      children: [
        %{
          object: "block",
          type: "paragraph",
          paragraph: %{
            text: [
              %{
                type: "text",
                text: %{
                  content: content
                }
              }
            ]
          }
        }
      ]
    }

    # TODO: cleanup how we render the data for the responses
    case HTTPoison.patch(url, Jason.encode!(body), headers) do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        if status === 200 do
          {:ok, Jason.decode!(body)}
        else
          {:error, Jason.decode!(body)}
        end
      _ -> {:error, "There was an error"}
    end
  end
end

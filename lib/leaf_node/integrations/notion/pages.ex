defmodule LeafNode.Integrations.Notion.Pages do
  @moduledoc """
  The Notion integrations and helper functions in order to interact with it
  """
  require Logger
  @notion_version "2021-05-13"
  @block_limit 100
  @block_text_str_limit 500

  @keys_to_remove [
    "archived",
    "created_by",
    "created_time",
    "has_children",
    "id",
    "in_trash",
    "last_edited_by",
    "last_edited_time",
    "object",
    "parent"
  ]

  def input_info() do
    [
      {"page_id", "Page Id", "text", "The notion page id you will grant access for"},
    ]
  end

  def read_content(page_id, token) do
    url = "https://api.notion.com/v1/blocks/#{page_id}/children?page_size=#{@block_limit}"

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Notion-Version", @notion_version}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # We extract text or plain text if possible
        data = Enum.reduce(drop_keys(Jason.decode!(body)["results"], token), [], fn item, acc ->
          if is_nil(item["text"]) do
            acc
          else
            acc ++ [item["text"]]
          end
        end)
        {:ok, data}
      _ -> {:error, "There was an error"}
    end
  end

  # Fetch children blocks and return their processed text recursively
  defp fetch_children(block_id, token) do
    url = "https://api.notion.com/v1/blocks/#{block_id}/children"

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Notion-Version", @notion_version}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = drop_keys(Jason.decode!(body)["results"], token)
        {:ok, data}
      _ -> {:error, "There was an error"}
    end
  end

  # Drop keys we don't need and fetch nested text
  defp drop_keys([], _token), do: %{}
  defp drop_keys(data, token) do
    Enum.map(data, fn item ->
      type_data =
        Map.get(item, item["type"], %{})

      text_list = Map.get(type_data, "text")
      extracted_text = extract_plain_text(text_list, "plain_text")

      text =
        if item["has_children"] do
          # Fetch children recursively and accumulate the text
          {:ok, children} = fetch_children(item["id"], token)
          extracted_text <> " " <> Enum.join(Enum.map(children, fn child -> child["text"] end), " ")
        else
          extracted_text
        end

      Map.drop(item, @keys_to_remove)
      |> Map.delete(item["type"])
      |> Map.put("text", text)
    end)
  end

  # Extract the plain text from the block's rich_text objects
  defp extract_plain_text(nil, _), do: nil
  defp extract_plain_text([], _), do: nil
  defp extract_plain_text(data, "plain_text") do
    str = Enum.at(data, 0)["plain_text"]
    str |> String.slice(0, @block_text_str_limit)
  end
  defp extract_plain_text(data, "text") do
    Enum.at(data, 0)["text"]
  end
end

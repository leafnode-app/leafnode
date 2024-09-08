defmodule LeafNode.Integrations.Notion.Pages do
  @moduledoc """
  The Notion integrations and helper functions in order to interact with it
  """
  @notion_version "2021-05-13"
  @block_limit 200
  @block_text_str_limit 500

  # We dont need to process these keys for now
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
    "parent",
  ]

  # Form details
  def input_info() do
    [
      {"page_id", "Page Id", "text", "The notion page id you will grant access for"},
      # {"content", "Content", "text", "Content for the Notion page. Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.text_content]]."}
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
        # We only return type and text value for the non nil types
        data = Enum.reduce(drop_keys(Jason.decode!(body)["results"]), [], fn item, acc ->
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

  # Drop keyys we dont need and refute non relevant strings
  defp drop_keys([]), do: %{}
  defp drop_keys(data) do
    Enum.map(data, fn item ->
      type_data =
        Map.get(item, item["type"], %{})

      text_list = Map.get(type_data, "text")
      extracted_text = extract_plain_text(text_list)

      Map.drop(item, @keys_to_remove)
        |> Map.delete(item["type"])
        |> Map.put("text", extracted_text)
    end)
  end

  # We try get the text out the blocks
  # TODO: we can make this better and not check index?
  defp extract_plain_text(nil), do: nil
  defp extract_plain_text([]), do: nil
  defp extract_plain_text(data) do
    str = Enum.at(data, 0)["plain_text"]
    # we need to shorted the string of the text per block for token size
    str |> String.slice(0, @block_text_str_limit)
  end
end

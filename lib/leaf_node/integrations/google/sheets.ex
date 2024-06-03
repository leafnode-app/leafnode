defmodule LeafNode.Integrations.Google.Sheets do
  @moduledoc """
    The Google sheets integrations and helper functions in order to interact with it
  """
  alias LeafNode.Google.OAuth

  @doc """
    The metadata to get information on how to render the fields in order to interact with the interaction
  """
  # TODO: This could be changed to use json schema - we can then get this info based on selected type and render it
  def input_info(type) when type === :write do
    [
      {:token, :string},
      {:spreadsheet_id, :string},
      {:tab, :string},
      {:range_start, :string},
      {:range_end, :string},
      {:values, :string},
    ]
  end

  def input_info(type) when type === :get do
    [
      {:token, :string},
      {:spreadsheet_id, :string},
      {:tab, :string},
      {:range_start, :string},
      {:range_end, :string},
      {:values, :string}
    ]
  end

  def input_info(), do: raise("Not supported")

  @doc """
    Append values to google sheet
  """
  # LeafNode.Integrations.Google.Sheets.write_to_sheet(token, "1oFKM0fU74b_qmDzqunhb9qcVghwgybSPTS8VCzYxORE", "A1:D1", [["some", "value", "goes", "here"]])
  def write_to_sheet(token, spreadsheet_id, range, values) do
    # Specify the valueInputOption parameter
    # or "RAW" based on your requirement
    value_input_option = "USER_ENTERED"

    # Update the URL to include the valueInputOption parameter
    url =
      "https://sheets.googleapis.com/v4/spreadsheets/#{spreadsheet_id}/values/#{range}:append?valueInputOption=USER_ENTERED"

    headers = [
      {"Authorization", "Bearer #{token.access_token}"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{"values" => values})

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        {:error, %{status_code: status_code, body: response_body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{reason: reason}}
    end
  end
end

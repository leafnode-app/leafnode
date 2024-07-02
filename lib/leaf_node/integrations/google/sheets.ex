defmodule LeafNode.Integrations.Google.Sheets do
  @moduledoc """
    The Google sheets integrations and helper functions in order to interact with it
  """

  @doc """
    The metadata to get information on how to render the fields in order to interact with the interaction
  """
  # TODO: This could be changed to use json schema - we can then get this info based on selected type and render it
  def input_info() do
    [
      {"spreadsheet_id", "Spreadsheet Id", "text", "The ID of the spreadsheet. Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.spreadsheet_id]]."},
      {"tab", "Tab", "text", "The tab name of the associated spreadsheet. Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.tab_name]]."},
      {"range_start", "Range Start", "text", "The starting cell range (e.g., A1). Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.start_cell]]."},
      {"range_end", "Range End", "text", "The ending cell range (e.g., B10). Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.end_cell]]."},
      {"input", "Input", "text", "Comma-separated values to insert (e.g., this,is,a,test). Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.values]]."}
    ]
  end

  @doc """
    Append values to google sheet
  """
  # LeafNode.Integrations.Google.Sheets.write_to_sheet(token, "1oFKM0fU74b_qmDzqunhb9qcVghwgybSPTS8VCzYxORE", "A1:D1", [["some", "value", "goes", "here"]])
  def write_to_sheet(access_token, spreadsheet_id, range, values) do
    # Specify the valueInputOption parameter
    # or "RAW" based on your requirement

    # Update the URL to include the valueInputOption parameter
    url =
      "https://sheets.googleapis.com/v4/spreadsheets/#{spreadsheet_id}/values/#{range}:append?valueInputOption=USER_ENTERED"

    headers = [
      {"Authorization", "Bearer #{access_token}"},
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

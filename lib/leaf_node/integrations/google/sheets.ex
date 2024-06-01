defmodule LeafNode.Integrations.Google.Sheets do
  alias LeafNode.GoogleOAuth

  @doc """
    Get the account token details here
  """
  def get_service_account_token do
    :ok
  end

  @doc """
    Append values to google sheet
  """
  # LeafNode.Integrations.Google.Sheets.write_to_sheet(token, "1oFKM0fU74b_qmDzqunhb9qcVghwgybSPTS8VCzYxORE", "Sheet1!A1:D1", [["some", "value", "goes", "here"]])
  def write_to_sheet(token, spreadsheet_id, range, values) do
    # Specify the valueInputOption parameter
    value_input_option = "USER_ENTERED"  # or "RAW" based on your requirement

    # Update the URL to include the valueInputOption parameter
    url = "https://sheets.googleapis.com/v4/spreadsheets/#{spreadsheet_id}/values/#{range}:append?valueInputOption=USER_ENTERED"
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

defmodule LeafNode.Integrations.Google.Mail do
  @moduledoc """
    Send email with specific details to setup email credentials
  """

  @doc """
    The metadata to get information on how to render the fields in order to interact with the interaction
  """
  # TODO: This could be changed to use json schema - we can then get this info based on selected type and render it
  def input_info() do
    [
      {"recipient", "Recipient", "text", "Email recipient. Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.email]]."},
      {"subject", "Subject", "text", "Email subject. Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.title]]."},
      {"body", "Body", "textarea", "Email body. Use [[input.payload.any_key]] for dynamic data. E.g., [[input.payload.message]]."}
    ]
  end

  @doc """
    Send email function that sets up the body, details and sends off the email
  """
  def send_email(token, from, recipient, subject, body) do
    email = create_email(from, recipient, subject, body)
    send_request(token, email)
  end

  @doc """
    Create the email template that will be sent to the relevant
  """
  def create_email(from, recipient, subject, body) do
    email_body =
      """
      From: #{String.split(from, "@") |> Enum.at(0)} <#{from}>
      To: #{recipient}
      Subject: #{subject}
      MIME-Version: 1.0
      Content-Type: text/html; charset="UTF-8"

      #{body}

      <br />
      <br />
      Generated with <a href="https://leafnode.app" target="_blank">leafnode.app</a>.
      """

    # Gmail API requires URL-safe Base64 encoding
    Base.url_encode64(email_body, padding: false)
  end

  @doc """
    Send an email on behalf of the user
  """
  def send_request(access_token, email) do
    url = "https://www.googleapis.com/gmail/v1/users/me/messages/send"

    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{"raw" => email})

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

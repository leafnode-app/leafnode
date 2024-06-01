defmodule LeafNode.GoogleOAuth do
  @moduledoc """
    The Oatuh module for google to auth the details for the client secret
  """
  use OAuth2.Strategy

  @scope Application.compile_env(:scopes, :spreadsheet_read_write)
  @client_secret Application.compile_env(:client_secrets, :client_secret)
  @client_id Application.compile_env(:client_secrets, :client_id)
  @site "https://accounts.google.com"
  @authorize_url "https://accounts.google.com/o/oauth2/auth"
  @token_url "https://accounts.google.com/o/oauth2/token"

  def client do
    OAuth2.Client.new([
      # strategy: __MODULE__,
      client_id: @client_id,
      client_secret: @client_secret,
      site: @site,
      authorize_url: @authorize_url,
      token_url: @token_url
    ])
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url(client, redirect_uri) do
    OAuth2.Client.authorize_url!(client, redirect_uri: redirect_uri, scope: @scope)
  end

  def get_token(client, code, redirect_uri) do
    OAuth2.Client.get_token!(client, [code: code, redirect_uri: redirect_uri])
  end
end

defmodule LeafNode.Google.OAuth do
  @moduledoc """
    The Oatuh module for google to auth the details for the client secret
  """
  use OAuth2.Strategy
  require Logger

  @site "https://accounts.google.com"
  @authorize_url "https://accounts.google.com/o/oauth2/auth"
  @token_url "https://accounts.google.com/o/oauth2/token"
  @access_type "offline"
  # the user needs to do this and approve in order to get a refresh token we can use for later
  @approval_prompt "force"

  @doc """
    Generate a client instance with stratgy type based on what we want to have the client ade for
  """
  def client(strategy \\ nil) do
    opts_strategy = if strategy, do: [strategy: strategy], else: []
    opts_default = [
      client_id: config(:client_id),
      client_secret: config(:client_secret),
      site: @site,
      authorize_url: @authorize_url,
      token_url: @token_url
    ]

    opts = opts_strategy ++ opts_default
    OAuth2.Client.new(opts)
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  @doc """
    Generate an auth url in order to request access to the users relant scoped services
  """
  def authorize_url(client, redirect_uri) do
    OAuth2.Client.authorize_url!(
      client,
      redirect_uri: redirect_uri,
      scope: Enum.join(config(:scopes_list), " "),
      access_type: @access_type,
      approval_prompt: @approval_prompt
    )
  end
  def authorize_url(client, redirect_uri, params) do
    url = OAuth2.Client.authorize_url!(
      client,
      redirect_uri: redirect_uri,
      scope: Enum.join(config(:scopes_list), " "),
      access_type: @access_type,
      approval_prompt: @approval_prompt,
      state: Base.encode64(Jason.encode!(params))
    )
    Logger.debug(redirect_uri, label: "redirect_uri")
    Logger.debug(url, label: "URL")

    url
  end

  @doc """
    Get an auth token that can be stored along with a refresh token to use for reqeust against googer services
  """
  def get_token(client, code, redirect_uri) do
    OAuth2.Client.get_token!(client, [
      code: code,
      redirect_uri: redirect_uri,
      client_id: config(:client_id),
      client_secret: config(:client_secret),
      grant_type: "authorization_code"
    ])
  end

  @doc """
    Pass a refresh token to get a new refresh token that can be stored for the user
  """
  def refresh_token(refresh_token) do
    client = client(OAuth2.Strategy.Refresh)
    OAuth2.Client.get_token!(client, [
      refresh_token: refresh_token,
      client_id: config(:client_id),
      client_secret: config(:client_secret),
      grant_type: "refresh_token"
    ])
  end

  # config to get based off the application name
  def config(), do: Application.get_env(:leaf_node, :client_secrets_google)
  def config(key, default \\ nil), do: Keyword.get(config(), key, default)
end

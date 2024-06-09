defmodule LeafNode.Notion.OAuth do
  @moduledoc """
    The Oatuh module for notion to auth the details for the client secret
  """
  use OAuth2.Strategy

  @client_secret Application.compile_env(:client_secrets_notion, :client_secret)
  @client_id Application.compile_env(:client_secrets_notion, :client_id)
  @authorize_url "https://api.notion.com/v1/oauth/authorize"
  @token_url "https://api.notion.com/v1/oauth/token"
  @access_type "offline"
  # the user needs to do this and approve in order to get a refresh token we can use for later
  @approval_prompt "force"

  @doc """
    Generate a client instance with stratgy type based on what we want to have the client ade for
  """
  def client(strategy \\ nil) do
    opts_strategy = if strategy, do: [strategy: strategy], else: []

    opts_default = [
      client_id: @client_id,
      client_secret: @client_secret,
      authorize_url: @authorize_url
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
      access_type: @access_type,
      approval_prompt: @approval_prompt
    )
  end

  def authorize_url(client, redirect_uri, params) do
    OAuth2.Client.authorize_url!(
      client,
      redirect_uri: redirect_uri,
      state: Base.encode64(Jason.encode!(params))
    )
  end

  @doc """
    Get an auth token that can be stored along with a refresh token to use for reqeust against googer services
  """
  def get_token(code, redirect_uri) do
    encoded = Base.encode64("#{@client_id}:#{@client_secret}")
    body = %{
      code: code,
      redirect_uri: redirect_uri,
      grant_type: "authorization_code"
    }
    |> Jason.encode!() # Ensure to use Jason for encoding the map to a JSON string

    headers = [
      {"Content-type", "application/json"},
      {"Authorization", "Basic #{encoded}"}
    ]

    # TODO: this needs to be changed as there are other cases
    case HTTPoison.post(@token_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Jason.decode!()}
      _ -> {:error, "There was an error"}
    end
  end

  @doc """
    Pass a refresh token to get a new refresh token that can be stored for the user
  """
  def refresh_token(refresh_token) do
    client = client(OAuth2.Strategy.Refresh)

    OAuth2.Client.get_token!(client,
      refresh_token: refresh_token,
      client_id: @client_id,
      client_secret: @client_secret,
      grant_type: "refresh_token"
    )
  end
end

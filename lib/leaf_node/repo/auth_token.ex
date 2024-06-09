defmodule LeafNode.Repo.OAuthToken do
  import Ecto.Query
  alias LeafNode.Repo
  alias LeafNode.Schemas.OAuthToken

  def store_token(user_id, type, access_token, refresh_token \\ nil, expires_at \\ nil) do
    changeset = %OAuthToken{}
    |> OAuthToken.changeset(%{
      user_id: user_id,
      integration_type: type,
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: expires_at
    })

    IO.inspect(changeset)

    Repo.insert!(changeset)
  end

  def update_token(oauth_struct, access_token, refresh_token, expires_at) do
    Ecto.Changeset.change(oauth_struct, %{
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: expires_at
    })
  end

  @doc """
    Fetch a user oauth token for a given integration type
  """
  def get_token(user_id, integration_type) do
    Repo.one(from t in OAuthToken, where: t.user_id == ^user_id and t.integration_type == ^integration_type)
  end

  @doc """
    Check the refresh token and update if relevant
  """
  def refresh_token_check(
      %{ expires_at: expires_at, refresh_token: refresh_token, access_token: access_token } = oauth_struct,
      type
    ) when type === :google do
    if (System.os_time(:seconds) > expires_at) do
      %OAuth2.Client{ token: token} = LeafNode.Google.OAuth.refresh_token(refresh_token)

      # attempt to store token - the rescue will run if this fails for some reason
      updated_oauth = update_token(
        oauth_struct,
        token.access_token,
        token.refresh_token,
        token.expires_at
      )

      # return the new access token
      Map.get(updated_oauth.changes, :access_token)
    else
      access_token
    end
  end
end

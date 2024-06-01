defmodule LeafNode.Repo.OAuthToken do
  import Ecto.Query
  alias LeafNode.Repo
  alias LeafNode.Schemas.OAuthToken

  def store_token(user_id, integration_type, access_token, refresh_token, expires_at) do
    changeset = %OAuthToken{}
    |> OAuthToken.changeset(%{
      user_id: user_id,
      integration_type: integration_type,
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: expires_at
    })

    Repo.insert_or_update(changeset)
  end

  def get_token(user_id, integration_type) do
    Repo.one(from t in OAuthToken, where: t.user_id == ^user_id and t.integration_type == ^integration_type)
  end

  def refresh_token(token_info) do
    # TODO: Implement token refresh logic here
    IO.inspect(token_info, label: "token_info")
    :ok
  end
end

defmodule LeafNode.Schemas.OAuthToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias LeafNode.Hashed.HMAC
  alias LeafNode.Cloak.EctoTypes.Binary

  schema "oauth_tokens" do
    field :integration_type, :string
    field :access_token, Binary
    field :access_token_hash, HMAC
    field :refresh_token, Binary
    field :refresh_token_hash, HMAC
    field :expires_at, :integer
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def changeset(oauth_tokens, attrs) do
    oauth_tokens
    |> cast(attrs, [:user_id, :integration_type, :access_token, :access_token_hash, :refresh_token, :refresh_token_hash, :expires_at])
    |> unique_constraint([:user_id, :integration_type])
    |> validate_required([:user_id, :integration_type, :access_token])
    |> put_hashed_binary()
  end

  defp put_hashed_binary(changeset) do
    changeset
      |> put_change(:access_token_hash, get_field(changeset, :access_token_hash))
      |> put_change(:refresh_token_hash, get_field(changeset, :refresh_token_hash))
  end
end

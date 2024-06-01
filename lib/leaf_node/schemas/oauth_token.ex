defmodule LeafNode.Schemas.OAuthToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "oauth_tokens" do
    field :integration_type, :string # we need to use an enum type here of the integrations
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :integer
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def changeset(oauth_tokens, attrs) do
    oauth_tokens
    |> cast(attrs, [:user_id, :integration_type, :access_token, :refresh_token, :expires_at])
    |> validate_required([:user_id, :integration_type, :access_token])
  end
end

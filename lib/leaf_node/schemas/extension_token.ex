defmodule LeafNode.Schemas.ExtensionToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias LeafNode.Cloak.EctoTypes.{Binary}
  alias LeafNode.Hashed.HMAC

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "extension_tokens" do
    field :token, Binary
    field :token_hash, HMAC
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def changeset(oauth_tokens, attrs) do
    oauth_tokens
    |> cast(attrs, [:user_id, :token, :token_hash])
    |> validate_required([:user_id, :token])
    |> unique_constraint([:user_id, :token_hash])
    |> put_hashed_binary()
  end

  def put_hashed_binary(changeset) do
    changeset |> put_change(:token_hash, get_field(changeset, :token))
  end
end

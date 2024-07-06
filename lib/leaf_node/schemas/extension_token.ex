defmodule LeafNode.Schemas.ExtensionToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "extension_tokens" do
    field :token, :string
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def changeset(oauth_tokens, attrs) do
    oauth_tokens
    |> cast(attrs, [:user_id, :token])
    |> unique_constraint([:user_id, :token])
    |> validate_required([:user_id, :token])
  end
end

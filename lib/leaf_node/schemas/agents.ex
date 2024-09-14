defmodule LeafNode.Schemas.Agent do
  use Ecto.Schema
  import Ecto.Changeset
  alias LeafNode.Hashed.HMAC
  alias LeafNode.Cloak.EctoTypes.Binary

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "agents" do
    field :email, Binary
    field :email_hash, HMAC
    field :name, :string
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def changeset(agents, attrs) do
    agents
    |> cast(attrs, [:email, :email_hash, :name, :user_id])
    |> unique_constraint([:user_id, :email])
    |> validate_required([:user_id, :email])
    |> put_hashed_binary()
  end

  defp put_hashed_binary(changeset) do
    changeset
      |> put_change(:email_hash, get_field(changeset, :email_hash))
  end
end

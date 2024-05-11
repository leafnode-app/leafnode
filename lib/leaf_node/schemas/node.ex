defmodule LeafNode.Schemas.Node do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "nodes" do
    field :title, :string
    field :description, :string
    field :enabled, :boolean, default: true
    field :should_log, :boolean, default: true
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def changeset(node, attrs) do
    node
    |> cast(attrs, [:title, :description, :enabled, :should_log, :user_id])
    |> validate_required([:title, :description, :enabled, :should_log, :user_id])
    |> assoc_constraint(:user)
  end
end

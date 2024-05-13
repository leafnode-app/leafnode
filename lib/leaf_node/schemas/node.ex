defmodule LeafNode.Schemas.Node do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "nodes" do
    field :expected_payload, :map, default: %{}
    field :title, :string, default: "Node - Name"
    field :description, :string, default: "Node - Description"
    field :enabled, :boolean, default: true
    field :should_log, :boolean, default: true
    field :access_key, :string
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def changeset(node, attrs) do
    node
    |> cast(attrs, [:title, :description, :enabled, :should_log, :expected_payload, :user_id, :access_key])
    |> validate_required([:title, :description, :enabled, :should_log, :expected_payload, :user_id, :access_key])
    |> assoc_constraint(:user)
  end
end

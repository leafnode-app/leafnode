defmodule LeafNode.Schemas.Augmentation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "augmentations" do
    field :type, :string, default: ""
    field :value, :string, default: ""
    field :enabled, :boolean
    field :async, :boolean
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def changeset(augment, attrs) do
    augment
    |> cast(attrs, [:type, :value, :enabled, :node_id, :async])
    |> validate_required([:enabled, :node_id, :async])
    |> assoc_constraint(:node)
  end
end

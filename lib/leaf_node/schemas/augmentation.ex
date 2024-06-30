defmodule LeafNode.Schemas.Augmentation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "augmentations" do
    field :type, :string, default: ""
    field :value, :string, default: ""
    field :enabled, :boolean
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:type, :value, :enabled, :node_id])
    |> validate_required([:value, :enabled, :node_id])
    |> assoc_constraint(:node)
  end
end

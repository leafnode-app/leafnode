defmodule LeafNode.Schemas.Expression do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "expressions" do
    field :input, :string
    field :expression, :string
    field :type, :string
    field :value, :string
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:node_id, :input, :expression, :type, :value])
    |> validate_required([:node_id, :input, :expression, :type, :value])
    |> unique_constraint(:node_id, message: "Each node can only have one expression")
    |> assoc_constraint(:node)
  end
end

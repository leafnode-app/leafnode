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
    field :enabled, :boolean
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:node_id, :input, :expression, :type, :value, :enabled])
    |> validate_required([:node_id, :expression, :type, :enabled])
    |> unique_constraint(:node_id, message: "Each node can only have one expression")
    |> assoc_constraint(:node)
  end
end

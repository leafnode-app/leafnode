defmodule LeafNode.Schemas.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "logs" do
    field :input, :map, default: %{} # TODO: encrypt
    field :result, :map, default: %{} # TODO: encrypt
    field :status, :boolean
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:input, :result, :status, :node_id])
    |> validate_required([:input, :result, :status, :node_id])
    |> assoc_constraint(:node)
  end
end

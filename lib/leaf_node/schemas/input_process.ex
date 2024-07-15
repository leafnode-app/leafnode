defmodule LeafNode.Schemas.InputProcess do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "input_processes" do
    field :type, :string, default: ""
    field :value, :string, default: ""  # TODO: encrypt
    field :enabled, :boolean
    field :async, :boolean
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def changeset(input_process, attrs) do
    input_process
    |> cast(attrs, [:type, :value, :enabled, :node_id, :async])
    |> validate_required([:enabled, :node_id, :async])
    |> assoc_constraint(:node)
  end
end

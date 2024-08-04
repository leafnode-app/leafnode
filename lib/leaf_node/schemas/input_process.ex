defmodule LeafNode.Schemas.InputProcess do
  use Ecto.Schema
  import Ecto.Changeset
  alias LeafNode.Cloak.EctoTypes.{Binary}
  alias LeafNode.Hashed.HMAC

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "input_processes" do
    field :type, Binary
    field :type_hash, HMAC
    field :value, Binary
    field :value_hash, HMAC
    field :enabled, :boolean
    field :async, :boolean
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def changeset(input_process, attrs) do
    input_process
    |> cast(attrs, [:type, :type_hash, :value, :value_hash, :enabled, :node_id, :async])
    |> validate_required([:enabled, :node_id, :async])
    |> assoc_constraint(:node)
  end
end

defmodule LeafNode.Schemas.Expression do
  use Ecto.Schema
  import Ecto.Changeset
  alias LeafNode.Cloak.EctoTypes.{Binary}
  alias LeafNode.Hashed.HMAC

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "expressions" do
    field :input, Binary
    field :input_hash, HMAC
    field :expression, Binary
    field :expression_hash, HMAC
    field :type, Binary
    field :type_hash, HMAC
    field :value, Binary
    field :value_hash, HMAC
    field :enabled, :boolean
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def changeset(expression, attrs) do
    expression
    |> cast(attrs, [:node_id, :input, :input_hash, :expression, :expression_hash, :type, :type_hash, :value, :value_hash, :enabled])
    |> validate_required([:node_id, :expression, :type, :enabled])
    |> unique_constraint(:node_id, message: "Each node can only have one expression")
    |> assoc_constraint(:node)
    |> put_hashed_binary()
  end

  def put_hashed_binary(changeset) do
    changeset
      |> put_change(:input_hash, get_field(changeset, :input))
      |> put_change(:expression_hash, get_field(changeset, :expression))
      |> put_change(:type_hash, get_field(changeset, :type))
      |> put_change(:value_hash, get_field(changeset, :value))
  end
end

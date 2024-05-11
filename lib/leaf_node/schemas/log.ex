defmodule LeafNode.Schemas.Log do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "logs" do
    field :input, :map, default: %{}
    field :result, :map, default: %{}
    field :status, :boolean
    belongs_to :node, LeafNode.Schemas.Node

    timestamps()
  end

  def get_logs_by_node(node_id) do
    query = from n in __MODULE__, where: n.node_id == ^node_id
    LeafNode.Repo.all(query)
  end

  def get_log(id) do
    LeafNode.Repo.get(__MODULE__, id)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:input, :result, :status, :node_id])
    |> validate_required([:input, :result, :status, :node_id])
    |> assoc_constraint(:node)
  end
end

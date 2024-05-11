defmodule LeafNode.Schemas.Node do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "nodes" do
    field :expected_payload, :map, default: %{}
    field :title, :string
    field :description, :string
    field :enabled, :boolean, default: true
    field :should_log, :boolean, default: true
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def get_nodes_by_user(user_id) do
    query = from n in __MODULE__, where: n.user_id == ^user_id
    LeafNode.Repo.all(query)
  end

  def get_node(id) do
    LeafNode.Repo.get(__MODULE__, id)
  end

  def changeset(node, attrs) do
    node
    |> cast(attrs, [:title, :description, :enabled, :should_log, :expected_payload, :user_id])
    |> validate_required([:title, :description, :enabled, :should_log, :expected_payload, :user_id])
    |> assoc_constraint(:user)
  end
end

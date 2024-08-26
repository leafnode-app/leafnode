defmodule LeafNode.Schemas.Node do
  use Ecto.Schema
  import Ecto.Changeset
  alias LeafNode.Hashed.HMAC
  alias LeafNode.Cloak.EctoTypes.{Binary, Map}
  alias LeafNode.Schemas.NodeSettings

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "nodes" do
    field :expected_payload, Map
    field :title, :string, default: "Node - Name"
    field :description, :string, default: "Node - Description"
    field :enabled, :boolean, default: true
    field :should_log, :boolean, default: true
    field :access_key, Binary
    field :access_key_hash, HMAC
    field :integration_settings, Map
    field :email, Binary
    field :email_hash, HMAC
    belongs_to :user, LeafNode.Accounts.User, foreign_key: :user_id, type: :integer

    timestamps()
  end

  def changeset(node, attrs) do
    node
    |> cast(attrs, [:title, :description, :enabled, :should_log, :expected_payload, :user_id, :access_key, :access_key_hash, :email, :email_hash, :integration_settings])
    |> validate_required([:title, :description, :enabled, :should_log, :user_id])
    |> validate_settings()
    |> assoc_constraint(:user)
    |> put_hashed_binary()
  end

  defp put_hashed_binary(changeset) do
    changeset
      |> put_change(:access_key_hash, get_field(changeset, :access_key))
      |> put_change(:email_hash, get_field(changeset, :email))
  end

  defp validate_settings(changeset) do
    integration_settings = get_field(changeset, :integration_settings)

    case NodeSettings.new(integration_settings) do
      {:ok, _settings} -> changeset
      {:error, reason} -> add_error(changeset, :integration_settings, reason)
    end
  end
end

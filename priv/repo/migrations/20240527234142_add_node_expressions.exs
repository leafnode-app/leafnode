defmodule LeafNode.Repo.Migrations.AddNodeExpressions do
  use Ecto.Migration

  def change do
    create table(:expressions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :input, :string, null: false
      add :expression, :string, null: false
      add :type, :string, null: false
      add :value, :string, null: false
      add :node_id, references(:nodes, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:expressions, [:node_id], name: :unique_node_expression)
  end
end

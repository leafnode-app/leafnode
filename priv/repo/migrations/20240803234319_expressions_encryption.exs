defmodule LeafNode.Repo.Migrations.ExpressionsEncryption do
  use Ecto.Migration

  def change do
    rename table(:expressions), to: table(:expressions_old)

    create table(:expressions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :input, :binary
      add :input_hash, :binary
      add :expression, :binary
      add :expression_hash, :binary
      add :type, :binary
      add :type_hash, :binary
      add :value, :binary
      add :value_hash, :binary
      add :enabled, :boolean
      add :node_id, references(:nodes, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:expressions, [:node_id], name: :unique_node_expression)
  end
end

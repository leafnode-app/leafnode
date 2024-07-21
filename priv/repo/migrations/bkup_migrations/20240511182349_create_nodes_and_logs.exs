defmodule LeafNode.Repo.Migrations.CreateNodesAndLogs do
  use Ecto.Migration

  def change do
    create table(:nodes, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :description, :string, null: false
      add :enabled, :boolean, null: false, default: true

      timestamps()
    end

    create index(:nodes, [:user_id])

    create table(:logs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :node_id, references(:nodes, type: :uuid, on_delete: :delete_all), null: false
      add :input, :map, default: %{}
      add :result, :map, default: %{}
      add :status, :boolean, null: false

      timestamps()
    end

    create index(:logs, [:node_id])
  end
end

defmodule LeafNode.Repo.Migrations.LogEncryption do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :node_id, references(:nodes, type: :uuid, on_delete: :delete_all), null: false
      add :input, :binary
      add :result, :binary
      add :status, :boolean

      timestamps()
    end

    create index(:logs, [:node_id])
  end
end

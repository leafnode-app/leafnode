defmodule LeafNode.Repo.Migrations.InputProcesses do
  use Ecto.Migration

  def change do
    create table(:input_processes, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :node_id, references(:nodes, type: :uuid, on_delete: :delete_all), null: false
      add :type, :string, default: "ai"
      add :value, :string, default: ""
      add :enabled, :boolean, null: false

      timestamps()
    end

    create index(:input_processes, [:node_id])
    create unique_index(:input_processes, [:node_id], name: :unique_node_input_process)
  end
end

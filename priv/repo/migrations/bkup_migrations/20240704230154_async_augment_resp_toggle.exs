defmodule LeafNode.Repo.Migrations.AsyncInputProcessesRespToggle do
  use Ecto.Migration

  def change do
    alter table(:input_processes) do
      add :async, :boolean, null: false, default: true
    end
  end
end

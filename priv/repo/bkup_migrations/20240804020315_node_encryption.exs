defmodule LeafNode.Repo.Migrations.NodeEncryption do
  use Ecto.Migration

  def change do
    create table(:nodes, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :description, :string, null: false
      add :enabled, :boolean, null: false, default: true
      add :should_log, :boolean, default: true
      add :expected_payload, :binary
      add :access_key, :binary
      add :access_key_hash, :binary
      add :integration_settings, :binary

      timestamps()
    end

    create index(:nodes, [:user_id])
  end
end

defmodule LeafNode.Repo.Migrations.AddAgentDetails do
  use Ecto.Migration

  def change do
    create table(:agents, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :email, :binary
      add :email_hash, :binary
      add :name, :string, default: ""
      timestamps()
    end

    # Unique index that we want to make sure each assistant cant have duplicates of
    create unique_index(:agents, [:user_id, :email])
    # index whhat we we will constantly query against for data against the assistant
    create index(:agents, [:user_id])
  end
end

defmodule LeafNode.Repo.Migrations.TextSoftDelete do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      add :is_deleted, :boolean, default: false
    end
  end
end

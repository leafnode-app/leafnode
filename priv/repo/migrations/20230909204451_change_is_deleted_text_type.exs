defmodule LeafNode.Repo.Migrations.ChangeSoftDeleteType do
  use Ecto.Migration

  def up do
    alter table(:texts) do
      modify :is_deleted, :string, using: "is_deleted::string"
    end
  end

  def down do
    alter table(:texts) do
      modify :is_deleted, :boolean, using: "is_deleted::boolean"
    end
  end
end

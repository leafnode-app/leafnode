defmodule LeafNode.Repo.Migrations.AdvancedFlag do
  use Ecto.Migration

  def change do
    alter table :users do
      add :advanced, :boolean, default: false
    end
  end
end

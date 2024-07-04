defmodule LeafNode.Repo.Migrations.AsyncAugmentRespToggle do
  use Ecto.Migration

  def change do
    alter table(:augmentations) do
      add :async, :boolean, null: false, default: true
    end
  end
end

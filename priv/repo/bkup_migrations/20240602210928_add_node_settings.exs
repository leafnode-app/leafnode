defmodule LeafNode.Repo.Migrations.AddNodeSettings do
  use Ecto.Migration

  def change do
    alter table("nodes") do
      add :settings, :map, default: %{}
    end
  end
end

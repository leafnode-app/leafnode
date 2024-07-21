defmodule LeafNode.Repo.Migrations.AddNodeLogToggle do
  use Ecto.Migration

  def change do
    alter table("nodes") do
      add :should_log, :boolean, default: true
    end
  end
end

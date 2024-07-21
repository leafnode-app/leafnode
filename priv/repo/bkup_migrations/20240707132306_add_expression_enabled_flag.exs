defmodule LeafNode.Repo.Migrations.AddExpressionEnabledFlag do
  use Ecto.Migration

  def change do
    alter table(:expressions) do
      add :enabled, :boolean, null: false, default: true
    end
  end
end

defmodule LeafNode.Repo.Migrations.ExpressionKeysNullableChange do
  use Ecto.Migration

  def change do
    alter table(:expressions) do
      modify :input, :string, null: true, default: ""
      modify :value, :string, null: true, default: ""
    end
  end
end

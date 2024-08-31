defmodule LeafNode.Repo.Migrations.AddNodeEmail do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add :email, :binary
    end
  end
end

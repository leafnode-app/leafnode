defmodule LeafNode.Repo.Migrations.AddNodeEmailHash do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add :email_hash, :binary
    end
  end
end

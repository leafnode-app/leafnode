defmodule LeafNode.Repo.Migrations.UsersEmailToBinary do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE users ALTER COLUMN email TYPE bytea USING email::bytea")
    alter table :users do
      modify :email, :binary
      add :email_hash, :binary
    end
  end
end

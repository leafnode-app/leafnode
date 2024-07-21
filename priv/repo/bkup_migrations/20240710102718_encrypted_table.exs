defmodule LeafNode.Repo.Migrations.EncryptedTable do
  use Ecto.Migration

  # Setup binary encrypted stored values in the database
  def change do
    create table(:encrypted_types) do
      add :encrypted_binary, :binary
      add :encrypted_string, :binary
      add :encrypted_map, :binary
      add :encrypted_integer, :binary
      add :encrypted_boolean, :binary

      timestamps()
    end
  end
end

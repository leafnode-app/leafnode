defmodule LeafNode.Repo.Migrations.EncryptedHashFields do
  use Ecto.Migration

  def change do
    alter table(:encrypted_types) do
      add :encrypted_binary_hash, :binary
      add :encrypted_string_hash, :binary
      add :encrypted_map_hash, :binary
      add :encrypted_integer_hash, :binary
      add :encrypted_boolean_hash, :binary
    end
  end
end

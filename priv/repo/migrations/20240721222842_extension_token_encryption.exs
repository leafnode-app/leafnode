defmodule LeafNode.Repo.Migrations.ExtensionTokenEncryption do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE extension_tokens ALTER COLUMN token TYPE bytea USING token::bytea")
    alter table(:extension_tokens) do
      # Instead of modify, use execute to cast the column
      add :token_hash, :binary
    end

    # Drop the old indexes if they exist
    drop_if_exists index(:extension_tokens, [:id, :user_id, :token])
    drop_if_exists unique_index(:extension_tokens, [:user_id, :token], name: :unique_user_extension)

    # Create new indexes including the new token_hash column
    create index(:extension_tokens, [:id, :user_id, :token_hash])
    create unique_index(:extension_tokens, [:user_id, :token_hash], name: :unique_user_extension)
  end
end

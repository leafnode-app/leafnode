defmodule LeafNode.Repo.Migrations.OauthEncryption do
  use Ecto.Migration

  def change do
    create table(:oauth_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :integration_type, :string
      add :access_token, :binary
      add :access_token_hash, :binary
      add :refresh_token, :binary
      add :refresh_token_hash, :binary
      add :expires_at, :bigint

      timestamps()
    end

    create index(:oauth_tokens, [:user_id])
    create unique_index(:oauth_tokens, [:user_id, :integration_type])
  end
end

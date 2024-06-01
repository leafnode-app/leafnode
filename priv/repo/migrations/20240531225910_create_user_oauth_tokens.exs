defmodule LeafNode.Repo.Migrations.CreateUserOauthTokens do
  use Ecto.Migration

  def change do
    create table(:user_oauth_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :integration_type, :string, null: false
      add :access_token, :string, null: false
      add :refresh_token, :string
      add :expires_at, :utc_datetime

      timestamps()
    end

    create index(:user_oauth_tokens, [:user_id])
    create unique_index(:user_oauth_tokens, [:user_id, :integration_type])
  end

end

defmodule LeafNode.Repo.Migrations.UpdateExpiresAtTypeAccessToken do
  use Ecto.Migration

  def change do
    alter table(:oauth_tokens) do
      add :expires_at, :bigint
    end
  end
end

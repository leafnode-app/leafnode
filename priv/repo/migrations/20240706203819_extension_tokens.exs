defmodule LeafNode.Repo.Migrations.ExtensionTokens do
  use Ecto.Migration

  def change do
    create table(:extension_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :string, null: false

      timestamps()
    end

    create index(:extension_tokens, [:id, :user_id, :token])
    create unique_index(:extension_tokens, [:user_id, :token], name: :unique_user_extension)
  end
end

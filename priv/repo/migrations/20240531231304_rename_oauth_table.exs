defmodule LeafNode.Repo.Migrations.RenameOauthTable do
  use Ecto.Migration

  def change do
    rename table(:user_oauth_tokens), to: table(:oauth_tokens)
  end
end

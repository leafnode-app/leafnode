defmodule LeafNode.Repo.Migrations.AddNodeAccessToken do
  use Ecto.Migration

  def change do
    alter table("nodes") do
      add :access_key, :string
    end
  end
end

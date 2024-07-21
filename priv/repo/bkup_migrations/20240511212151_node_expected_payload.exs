defmodule LeafNode.Repo.Migrations.NodeExpectedPayload do
  use Ecto.Migration

  def change do
    alter table("nodes") do
      add :expected_payload, :map, default: %{}
    end
  end
end

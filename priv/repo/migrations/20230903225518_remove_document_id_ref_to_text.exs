defmodule LeafNode.Repo.Migrations.RemoveDocumentIdRefToText do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      remove :document_id
    end
  end
end

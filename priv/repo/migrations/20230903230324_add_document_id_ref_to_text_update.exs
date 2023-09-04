defmodule LeafNode.Repo.Migrations.AddDocumentIdRefToTextUpdate do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      add :document_id, :string
    end
  end
end

defmodule LeafNode.Repo.Migrations.CreateTexts do
  use Ecto.Migration

  def change do
    create table(:texts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :pseudo_code, :string, null: true
      add :data, :string, null: true
      add :document_id, references(:documents, type: :uuid)
      # This way we can order the texts in a document if the order matters
      add :order, :integer

      timestamps(type: :utc_datetime)
    end
  end
end

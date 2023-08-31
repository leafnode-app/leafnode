defmodule LeafNode.Repo.Migrations.AddDocuments do
  use Ecto.Migration

  def change do
    create table(:documents, primary_key: false) do
      # This allows setting a unique key as primary per document
      add :id, :uuid, primary_key: true
      add :name, :string, default: "Untitled Document"
      add :description, :string, null: true, default: "Description"
      add :result, :string, null: true # Using a string to store either boolean flag or text ID
      # The schema will add an association to have a one to may for this document to find its texts
      timestamps(type: :utc_datetime)
    end
  end
end

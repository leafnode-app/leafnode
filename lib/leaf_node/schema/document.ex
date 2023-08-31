defmodule LeafNode.Schema.Document do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "documents" do
    field :name, :string
    field :description, :string
    field :result, :string

    has_many :texts, LeafNode.Schema.Text # one-to-many relationship of this document to texts

    timestamps(type: :utc_datetime)
  end
end

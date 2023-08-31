defmodule LeafNode.Schema.Text do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "texts" do
    field :pseudo_code, :string
    field :data, :string

    belongs_to :document, LeafNode.Schema.Document  # Belongs-to relationship to Document

    timestamps(type: :utc_datetime)
  end
end

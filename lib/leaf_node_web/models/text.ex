defmodule LeafNodeWeb.Models.Text do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "texts" do
    field :pseudo_code, :string
    field :data, :string
    # The document it belonds to
    field :document_id, :string
    field :order, :integer
    field :is_deleted, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:pseudo_code, :data, :document_id, :order, :is_deleted])
  end
end

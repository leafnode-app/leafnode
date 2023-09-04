defmodule LeafNodeWeb.Models.Document do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "documents" do
    field :name, :string
    field :description, :string
    field :result, :string

    timestamps(type: :utc_datetime)
  end

  # Validation or changeset work needs to be done here to verify if we can do the calls
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :result])
  end
end

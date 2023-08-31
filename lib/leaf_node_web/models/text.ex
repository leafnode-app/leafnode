defmodule LeafNodeWeb.Models.Text do
  use Ecto.Schema
  # import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "texts" do
    field :pseudo_code, :string
    field :data, :string

    # Belongs-to relationship to Document
    belongs_to :document, LeafNodeWeb.Models.Document

    timestamps(type: :utc_datetime)
  end

  # Validation or changeset work needs to be done here to verify if we can do the calls

  # def changeset(struct, params \\ %{}) do
  #   struct
  #   |> cast(params, [:pseudo_code, :data])
  # end
end

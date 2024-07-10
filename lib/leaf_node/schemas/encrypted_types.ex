defmodule LeafNode.Schemas.EncryptedTypes do
  @moduledoc """
  This module is responsible for defining the encrypted types.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias LeafNode.Cloak.EctoTypes.{Binary, Integer, Map}

  schema "encrypted_types" do
    field :encrypted_binary, Binary
    field :encrypted_string, Binary
    field :encrypted_map, Map
    field :encrypted_integer, Integer
    field :encrypted_boolean, Binary

    timestamps()
  end

  @doc false
  def changeset(encrypted_types, attrs) do
    encrypted_types
    |> cast(attrs, [
      :encrypted_binary,
      :encrypted_string,
      :encrypted_map,
      :encrypted_integer,
      :encrypted_boolean
    ])
  end
end

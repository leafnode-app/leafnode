defmodule LeafNode.Schemas.EncryptedTypes do
  @moduledoc """
  This module is responsible for defining the encrypted types.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias LeafNode.Cloak.EctoTypes.{Binary, Integer, Map}
  alias LeafNode.Hashed.HMAC

  schema "encrypted_types" do
    field(:encrypted_binary, Binary)
    field(:encrypted_binary_hash, HMAC)
    field(:encrypted_string, Binary)
    # field(:encrypted_string_hash, :binary)
    field(:encrypted_map, Map)
    # field(:encrypted_map_hash, :binary)
    field(:encrypted_integer, Integer)
    # field(:encrypted_integer_hash, :binary)
    field(:encrypted_boolean, Binary)
    # field(:encrypted_boolean_hash, :binary)

    timestamps()
  end

  @doc false
  def changeset(encrypted_types, attrs) do
    encrypted_types
    |> cast(attrs, [
      :encrypted_binary,
      :encrypted_binary_hash,
      :encrypted_string,
      :encrypted_map,
      :encrypted_integer,
      :encrypted_boolean
    ])
    |> put_hashed_binary()

  end

  def put_hashed_binary(changeset) do
    changeset |> put_change(:encrypted_binary_hash, get_field(changeset, :encrypted_binary))
  end
end

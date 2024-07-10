defmodule LeafNode.Cloak.EctoTypes.Binary do
  @moduledoc """
  This module is responsible for handling binary data.
  We can use this for string types or any type that is not supported in the list we wish to encrypt
  """
  use Cloak.Ecto.Binary, vault: LeafNode.Cloak.Vault
end

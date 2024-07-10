defmodule LeafNode.Cloak.Vault do
  @moduledoc """
  This module is responsible for storing and retrieving secrets from the vault.
  """
  # See https://hexdocs.pm/cloak_ecto/Vault.html
  use Cloak.Vault, otp_app: :leaf_node
end

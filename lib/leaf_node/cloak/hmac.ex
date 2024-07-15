defmodule LeafNode.Hashed.HMAC do
  @moduledoc """
  This module is responsible for handling HMAC data.
  """
  # See https://hexdocs.pm/cloak_ecto/HMAC.html
  use Cloak.Ecto.HMAC, otp_app: :leaf_node
  # See the config for more information
end

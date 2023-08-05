defmodule LeafNode.Structs.Document do
  @moduledoc """
    The struct and definition of the Document
  """
  alias LeafNode.Structs.Paragraph

  defstruct [:id, :name, { :data, LeafNode.Structs.Paragraph }, { :result, false }]
end

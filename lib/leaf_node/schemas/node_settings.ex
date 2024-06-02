defmodule LeafNode.Schemas.NodeSettings do
  @moduledoc """
    Defines the settings for a Node.
  """

  @allowed_types ["none", "google_sheets"]

  defstruct type: nil, input: nil, has_oauth: false

  @type t :: %__MODULE__{
    type: String.t(),
    input: String.t(),
    has_oauth: boolean()
  }

  @doc """
  Creates a new NodeSettings struct with validations.
  """
  def new(attrs \\ %{}) do
    with :ok <- validate_type(attrs[:type]) do
      {:ok, %__MODULE__{
        type: attrs[:type],
        input: attrs[:input],
        has_oauth: Map.get(attrs, :has_oauth, false)
      }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_type(type) when type in @allowed_types, do: :ok
  defp validate_type(_), do: {:error, "Invalid type"}
end

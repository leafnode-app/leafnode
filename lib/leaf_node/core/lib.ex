defmodule LeafNode.Core.Lib do
  @moduledoc """
    General functions for outputting the inputs
  """

  @doc """
    Error responses either with no input and a default error or a custom error and data
  """
  def error(), do: %{"error" => "There was an error"}
  def error(msg, data \\ %{}) do
   %{ "error" =>
    %{
      "message" => msg,
      "meta_data" => Jason.encode!(data)
    }
   }
  end

  @doc """
    Return the same data that was in the input
  """
  def print(data) do
    data
  end
end

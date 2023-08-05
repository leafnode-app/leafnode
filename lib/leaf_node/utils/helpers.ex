defmodule LeafNode.Utils.Helpers do
  require Logger
  @moduledoc """
    The LeafNode.Utils.Helpers module provides a set of helper functions that can be used across different modules on the platform.
    The module includes a function for converting a list to a map and creating a parent key for the data on the current list item context.
    There is also a function for converting a list of strings to existing atoms, which can be useful for optimizing memory usage.
    Finally, the module provides a function for creating a formatted HTTP response to send to clients.

    Overall, the LeafNode.Utils.Helpers module provides a useful set of generic helper functions that can be used in many different contexts, helping to simplify and streamline Elixir application development.
  """

  @doc """
    Convert a map to a list using its keys as the list indices
  """
  def map_to_list(map) do
    Map.keys(map)
  end

  @doc """
    Convert a list to another type and have a key that will create map with a selected key as
    its parent key for the data on the current list item context
  """
  def list_to_map(list, type, key) do
    Enum.reduce(list, type, fn node, acc ->
      Map.put(acc, node[key], node)
    end)
  end

  @doc """
    Take a list of string and try to loop over them to turn them into atoms
  """
  def strings_to_existing_atoms(strings) do
    Enum.map(strings, fn item -> String.to_existing_atom(item) end)
  end

  @doc """
    A formatted response to send to the client
  """
  def http_resp(code, success, data \\ %{}) do
    %{
      "success" => success,
      "code" => code,
      "result" => data
    }
  end
end

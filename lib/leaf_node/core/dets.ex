defmodule LeafNode.Core.Dets do
  @moduledoc """
    Disk storage helper functions
  """
  @tables %{
    "documents" => :documents,
  }

  def get_system_tables() do
    @tables
  end

  @doc """
    Open or create a new table, this will default to 3min of flushing and closing from inactivity
  """
  def open_table(table, opts \\ []) do
    {_status, result} = :dets.open_file(table, opts)
    result
  end

  @doc """
    Insert a value to a key in dets
  """
  def insert(table, key, value) do
    :dets.insert(table, {key, value})
  end

  @doc """
    Remove item by key in dets
  """
  def delete(table, key) do
    :dets.delete(table, key)
  end

  @doc """
    Get data stored by key
  """
  def get_by_key(table, key) do
    case :dets.match_object(table, {key, :_}) do
      [{_, data}] -> {:ok, data}
      _ -> {:error, "Data not found"}
    end
  end

  @doc """
    Match all and return by table
  """
  def get_all(table) do
    data = :dets.match_object(table, {:_, :_})
    cond do
      Kernel.length(data) === 0 -> {:error, "No data found"}
      Kernel.length(data) > 0 -> {:ok, Enum.into(data, %{})}
      true -> {:error, "There was an error"}
    end
  end

  @doc """
    This will copy disk data into memory
  """
  def copy_to_ets(table) do
    {status, data} = get_all(table)

    case status do
      :ok ->
        Enum.each(data, fn {id, value} ->
          :ets.insert(table, {id, value})
        end)
      _ -> {:error, "Unable to copy to ets"}
    end
  end
end

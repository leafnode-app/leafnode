defmodule LeafNode.Core.Ets do
  @moduledoc """
    Methods for creating, inserting, retrieving and deleting items from memory storage tables.
    It also has a method for checking whether a table exists. The module returns JSON formatted data.
  """

  @tables %{
    "documents" => :documents
  }

  @doc """
    Return system tables that have been made
  """
  def get_system_tables do
    @tables
  end

  @doc """
    Create a new table

    Opts needs to be passed when creating the table to allow replacing and setting options
  """
  def create_table(table, opts) do
    :ets.new(table, opts)
  end

  @doc """
    Insert a new item to a given table
  """
  def insert(table, key, value) do
    :ets.insert_new(table, {key, value})
  end

  @doc """
    Lookup or find an item stored in table by key
  """
  def get_by_key(table, key) do
    case :ets.match_object(table, {key, :_}) do
      [{_, data}] -> {:ok, data}
      _ -> {:error, "Data not found"}
    end
  end

  @doc """
    Match all and return by table
  """
  def get_all(table) do
    processes = :ets.match_object(table, {:_, :_})

    case Enum.empty?(processes) do
      false -> {:ok, Enum.into(processes, %{})}
      _ -> {:error, "Data not found"}
    end
  end

  @doc """
    Remove item from table
  """
  def delete_by_key(table, key) do
    :ets.delete(table, key)
  end

  @doc """
    Check if a table exists
  """
  def table_exists?(table) do
    if :ets.whereis(table) === :undefined, do: false, else: true
  end
end

defmodule LeafNode.Core.SafeFunctions do
  @moduledoc """
    The functions available to execute that are allowed from a client interaction through a LLM

    @spec add(number, number) :: number
    @spec subtract(number, number) :: number
    @spec multiply(number, number) :: number
    @spec divide(number, number) :: number
    @spec value(boolean | string | number) :: boolean | string | number
    @spec ref(binary) :: term()
    @spec get_map_val(map, binary) :: term()
    @spec equals(term(), term()) :: boolean
    @spec not_equals(term(), term()) :: boolean
    @spec less_than(number, number) :: boolean
    @spec greater_than(number, number) :: boolean
    @spec input() :: map()

  """

  # whitelist functions we allow to execute
  @whitelist [
    "add",
    "subtract",
    "multiply",
    "divide",
    "value",
    "ref",
    "equals",
    "not_equals",
    "less_than",
    "greater_than",
    "input"
  ]

  @doc """
    The list of functions allowed to be used for dynamic execution
  """
  def allowed_functions() do
    @whitelist
  end

  @doc """
    Add two values together
  """
  def add(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    result = try do
      Enum.reduce(params, fn (idx, acc) ->
        idx + acc
      end)
    catch
      _type, _reason ->
        "There was an error adding values. Confirm values are numbers and/or correctly referenced"
    end

    {:ok, result}
  end

  @doc """
    Minus two values from eachother
  """
  def subtract(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    result = try do
      Enum.at(params, 0) - Enum.at(params, 1)
    catch
      _type, _reason ->
        "There was an error subtracting values. Confirm values are numbers and/or correctly referenced"
    end

    {:ok, result}
  end

  @doc """
    Multiply two values together
  """
  def multiply(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    result = try do
      Enum.at(params, 0) * Enum.at(params, 1)
    catch
      _type, _reason ->
        "There was an error multiplying values. Confirm values are numbers and/or correctly referenced"
    end

    IO.inspect(result)
    {:ok, result}
  end

  @doc """
    Divide a value against another
  """
  def divide(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    result = try do
      Enum.at(params, 0) / Enum.at(params, 1)
    catch
      _type, _reason ->
        "There was an error dividing values. Confirm values are numbers and/or correctly referenced"
    end

    {:ok, result}
  end

  @doc """
    Return the passed value
  """
  def value(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0)}
  end

  @doc """
    Reference or get data from another paragraph
  """
  def ref(item) do
    %{ "meta_data" => meta_data, "params" => params} = item

    {_status, result} = LeafNode.Agents.ExecutionHistoryAgent.get_by_key(
      Map.get(meta_data, "document_id"),
      Enum.at(params, 0)
    )

    {:ok, result}
  end

  @doc """
    Get a value from a map
  """
  def get_map_val(item) do
    raise "Not implemented for fn -> get_map_val"
    # Map.get(map, value)
  end

  @doc """
    Check if one value equals another
  """
  def equals(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0) === Enum.at(params, 1)}
  end

  @doc """
    Check if one value is not equal to another
  """
  def not_equals(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0) !== Enum.at(params, 1)}
  end

  @doc """
    Check if one value is less than another
  """
  def less_than(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0) < Enum.at(params, 1)}
  end

  @doc """
    Check if one value is greater than another
  """
  def greater_than(item) do
    %{ "meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0) > Enum.at(params, 1)}
  end

  @doc """
    Get the input value passed
  """
  def input(item) do
    raise "Not implemented for fn -> input"
    # TODO: at runtime we need to pass the input that is passed with execution
    # {:ok, input}
  end
end

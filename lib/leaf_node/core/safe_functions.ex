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
  def add({_, a}, {_, b}) do
    IO.inspect(a)
    IO.inspect(b)
    {:ok, a + b}
  end

  @doc """
    Minus two values from eachother
  """
  def subtract(a, b) do
    a - b
  end

  @doc """
    Multiply two values together
  """
  def multiply(a, b) do
    a * b
  end

  @doc """
    Divide a value against another
  """
  def divide(a, b) do
    a / b
  end

  @doc """
    Return the passed value
  """
  def value(item) do
    item
  end

  @doc """
    Reference or get data from another paragraph
  """
  def ref(id) do
    # TODO: Get the result of a prev executed function by the id of the paragraph
    {:ok, 10}
  end

  @doc """
    Get a value from a map
  """
  def get_map_val(map, value) do
    Map.get(map, value)
  end

  @doc """
    Check if one value equals another
  """
  def equals(a, b) do
    a === b
  end

  @doc """
    Check if one value is not equal to another
  """
  def not_equals(a, b) do
    a !== b
  end

  @doc """
    Check if one value is less than another
  """
  def less_than(a, b) do
    a < b
  end

  @doc """
    Check if one value is greater than another
  """
  def greater_than(a, b) do
    a > b
  end

  @doc """
    Get the input value passed
  """
  def input(input) do
    # TODO: at runtime we need to pass the input that is passed with execution
    input
  end
end

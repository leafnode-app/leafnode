defmodule LeafNode.Core.Code do
  @moduledoc """
    The module that we will use for core functionality to check and generate code.
    We can use this to convert to and from text <-> code and hold whitelist of functions
  """

  require Logger

  @doc """
    We execute the function that was passed based on permission
  """
  def execute(func_string, execution_history) do
    case Code.string_to_quoted(func_string) do
      {:ok, ast} ->
        case evaluate_ast(ast, execution_history) do
          {:ok, result} -> {:ok, result}
          {:error, reason} ->
            Logger.error("Error executing function: #{reason}")
            {:error, "Error executing function"}
        end
      {:error, reason} ->
        Logger.error("Unable to parse function string: #{inspect(reason)}")
        {:error, "Unable to parse function string"}
    end
  end

  @doc """
    Check if we are permitted to use the function
  """
  defp evaluate_ast({func_atom, _, args}, execution_history) when is_atom(func_atom) do
    func_string = Atom.to_string(func_atom)
    allowed_functions = LeafNode.Core.SafeFunctions.allowed_functions()
    if Enum.member?(allowed_functions, func_string) do
      # we need to get the value from the keyword list, the result
      evaluated_args = Enum.map(args, fn item ->
        case evaluate_ast(item, execution_history) do
          {_, value} -> value
          [_: value] -> value
        end
      end)

      apply(LeafNode.Core.SafeFunctions, func_atom, evaluated_args ++ [execution_history])
    else
      {:error, "Function #{func_string} is not allowed"}
    end
  end

  # the base and last value that will be executed to the safe functions
  defp evaluate_ast(value, _execution_history) do
    {:ok, value}
  end
end

# GenServer.call(LeafNode.Servers.ExecutionServer, {:execute, "2a591b73-0c39-4fd1-af09-ae5252f738c6"}, 10000)

defmodule LeafNode.Core.Code do
  @moduledoc """
    The module that we will use for core functionality to check and generate code.
    We can use this to convert to and from text <-> code and hold whitelist of functions
  """

  require Logger

  @doc """
    We execute the function that was passed based on permission
  """
  def execute(func_string) do
    case Code.string_to_quoted(func_string) do
      {:ok, ast} ->
        case evaluate_ast(ast) do
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
  defp evaluate_ast({func_atom, _, args}) when is_atom(func_atom) do
    func_string = Atom.to_string(func_atom)
    allowed_functions = LeafNode.Core.SafeFunctions.allowed_functions()

    if Enum.member?(allowed_functions, func_string) do
      evaluated_args = Enum.map(args, &evaluate_ast/1)
      apply(LeafNode.Core.SafeFunctions, func_atom, evaluated_args)
    else
      {:error, "Function #{func_string} is not allowed"}
    end
  end

  defp evaluate_ast(value) do
    {:ok, value}
  end
end

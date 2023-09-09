defmodule LeafNode.Core.Code do
  @moduledoc """
    The module that we will use for core functionality to check and generate code.
    We can use this to convert to and from text <-> code and hold whitelist of functions
  """

  require Logger
  @doc """
    We execute the function that was passed based on permission
  """
  # TODO: Too many inputs here!
  def execute(func_string, document_id, text_id, payload) do
    case Code.string_to_quoted(func_string) do
      {:ok, ast} ->
        case evaluate_ast(ast, document_id, text_id, payload) do
          {:ok, result} ->
            # We assume the server is up - we can start up later if needed
            GenServer.call(String.to_atom("history_" <> document_id), {:set_history, text_id, result})
            # return for execution purposes but we dont need this
            {:ok, result}
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
  defp evaluate_ast({func_atom, _, args}, document_id, text_id, payload) when is_atom(func_atom) do
    func_string = Atom.to_string(func_atom)
    allowed_functions = LeafNode.Core.SafeFunctions.allowed_functions()
    if Enum.member?(allowed_functions, func_string) do
      # we need to get the value from the keyword list, the result
      evaluated_args = Enum.map(args, fn item ->
        case evaluate_ast(item, document_id, text_id, payload) do
          {_, value} -> value
          [_: value] -> value
        end
      end)

      # created a payload with metadata
      input = %{
        "payload" => payload,
        "params" => evaluated_args,
        "meta_data" => %{
          "document_id" => document_id,
          "text_id" => text_id,
          "type" => func_string
        }
      }
      apply(LeafNode.Core.SafeFunctions, func_atom, [input])
    else
      {:error, "Function #{func_string} is not allowed"}
    end
  end

  # the base and last value that will be executed to the safe functions
  defp evaluate_ast(value, _document_id, _text_id, _payload) do
    {:ok, value}
  end
end

# GenServer.call(LeafNode.Servers.ExecutionServer, {:execute, "2a591b73-0c39-4fd1-af09-ae5252f738c6"}, 10000)

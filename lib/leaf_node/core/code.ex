defmodule LeafNode.Core.Code do
  @moduledoc """
    The module that we will use for core functionality to check and generate code.
    We can use this to convert to and from text <-> code and hold whitelist of functions
  """

  require Logger

  @doc """
    Check if we are permitted to use the function
  """
  def check_ast_permission(func) do
    case Code.string_to_quoted!(func) do
      {func, _, _params} ->
        func_str = Atom.to_string(func)
        if Enum.member?(LeafNode.Core.SafeFunctions.allowed_functions(), func_str) do
          {:ok, true}
        else
          {:ok, false}
        end
      _ ->
        {:error, "There was an error quoting the passed function"}
    end
  end

  @doc """
    We execute the function that was passed based on permission
  """
  def execute(func) do
    {status, result} = check_ast_permission(func)

    case status do
      :ok ->
        if result do
          # Prepend the module name to the function string
          func_with_module = "LeafNode.Core.SafeFunctions.#{func}"
          IO.inspect(func_with_module)

          {eval_result, _binding} = Code.eval_string(func_with_module)
          {:ok, eval_result}
        else
          Logger.error("Unable to execute function, make sure the function exists and is whitelisted")
          {:error, "Error executing function"}
        end
      _ ->
        Logger.error("There was an error executing the passed function")
        {:error, "There was an error executing the function"}
    end
  end

end

defmodule LeafNode.Core.Code do
  @moduledoc """
  The module that we will use for core functionality to check and generate code.
  We can use this to convert to and from text <-> code and hold whitelist of functions.
  """
  require Logger

  @doc """
  Execute the function that was passed based on permission.
  """
  def execute(payload, %{id: _, input: input, type: type, value: value, expression: expression}) do
      try do
        # Try to get the input value based on the selected input path
        payload_value = Kernel.get_in(payload, String.split(input, "."))

        # Convert the stored value to the relevant type
        case type_conversion(value, type) do
          {:ok, converted_value} ->
            # Compare the payload value against the converted value using the expression
            result = compare(payload_value, converted_value, expression)
            IO.inspect(result, label: "Comparison Result")
            {:ok, result}

          {:error, reason} ->
            Logger.error("Type conversion error: #{reason}")
            {:error, reason}
        end
      catch
        _type, _reason ->
          {:error, false}
      end
  end

  # Convert the stored value to the relevant type
  defp type_conversion(value, type) when type === "string" do
    {:ok, to_string(value)}
  end

  defp type_conversion(value, type) when type === "integer" do
    case Integer.parse(value) do
      {int, ""} -> {:ok, int}
      _ -> {:error, "Unable to execute as value can't be converted to type integer"}
    end
  end

  defp type_conversion(value, type) when type === "boolean" do
    case value do
      true -> {:ok, true}
      false -> {:ok, false}
      "true" -> {:ok, true}
      "false" -> {:ok, false}
      _ -> {:error, "Unable to execute as value can't be converted to type boolean"}
    end
  end

  defp type_conversion(_, _type) do
    {:error, "Unsupported type"}
  end

  # Compare the payload value against the converted value using the expression
  defp compare(nil, _, _), do: false

  defp compare(payload_value, converted_value, expression) do
    case expression do
      "===" -> payload_value === converted_value
      "!=" -> payload_value != converted_value
      ">" -> payload_value > converted_value
      ">=" -> payload_value >= converted_value
      "<" -> payload_value < converted_value
      "<=" -> payload_value <= converted_value
      _ -> false
    end
  end
end

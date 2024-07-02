defmodule LeafNode.Core.Interpolator do
  @moduledoc """
    Used to take string template data and convert it with the values of the passed data to the input
  """
  @placeholder_pattern ~r/\[\[([a-zA-Z0-9_\.]+)\]\]/

  @doc """
    Regular expression  to find dynamic data in template
  """
  def interpolate_string(template, payload) when is_list(template) do
    Enum.map(template, fn item ->
      replace_template_variables(item, payload)
    end)
  end
  def interpolate_string(template, data) do
    replace_template_variables(template, data)
  end

  # take the template and replace variable placeholders
  defp replace_template_variables(template, data) do
    Regex.replace(@placeholder_pattern, template, fn _, match ->
      match
      |> String.split(".")
      |> get_value(data)
      |> to_string()
      |> case do
        "" -> "[[" <> match <> "]]"
        value -> value
      end
    end)
  end

  # Get the value associated with the string notation selection agaisnt the passed map
  defp get_value([key | rest], data) do
    case Map.fetch(data, key) do
      {:ok, value} when rest == [] -> value
      {:ok, value} -> get_value(rest, value)
      :error -> "[[" <> Enum.join([key | rest], ".") <> "]]"
    end
  end
end

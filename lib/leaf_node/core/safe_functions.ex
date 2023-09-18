defmodule LeafNode.Core.SafeFunctions do
  @moduledoc """
    The functions available to execute that are allowed from a client interaction through a LLM
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
    "input",
    "get_map_val",
    "send_slack_message"
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
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item

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
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
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
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
    result = try do
      Enum.at(params, 0) * Enum.at(params, 1)
    catch
      _type, _reason ->
        "There was an error multiplying values. Confirm values are numbers and/or correctly referenced"
    end

    {:ok, result}
  end

  @doc """
    Divide a value against another
  """
  def divide(item) do
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
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
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0)}
  end

  @doc """
    Reference or get data from another paragraph
  """
  def ref(item) do
    %{ "meta_data" => meta_data, "params" => params} = item

    doc_id = Map.get(meta_data, "document_id")

    result = try do
    {_status, result} =
      GenServer.call(
        String.to_atom("history_" <> Map.get(meta_data, "document_id")), {:get_by_key, Enum.at(params, 0)})
      result
    catch
      _type, _reason ->
      "There was a problem getting the data referencing the text block: #{doc_id}"
    end

    {:ok, result}
  end

  @doc """
    Get a value from a map
  """
  def get_map_val(item) do
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
    payload_input = Enum.at(params, 0)
    location_param = Enum.at(params, 1)
    {:ok, Kernel.get_in(payload_input, String.split(location_param, "."))}
  end

  @doc """
    Check if one value equals another
  """
  def equals(item) do
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0) === Enum.at(params, 1)}
  end

  @doc """
    Check if one value is not equal to another
  """
  def not_equals(item) do
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0) !== Enum.at(params, 1)}
  end

  @doc """
    Check if one value is less than another
  """
  def less_than(item) do
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0) < Enum.at(params, 1)}
  end

  @doc """
    Check if one value is greater than another
  """
  def greater_than(item) do
    %{ "payload" => _ ,"meta_data" => _meta_data, "params" => params} = item
    {:ok, Enum.at(params, 0) > Enum.at(params, 1)}
  end

  @doc """
    Get the input value passed
  """
  def input(item) do
    %{ "payload" => payload ,"meta_data" => _meta_data, "params" => _params} = item
    {:ok, payload}
  end

  @doc """
    Send to slack channel
  """
  def send_slack_message(item) do
    %{ "payload" => _payload ,"meta_data" => _meta_data, "params" => params} = item

    result = try do
      # Payload for slack text
      payload = %{
        "text" => to_string(Enum.at(params, 0))
      }

      # request to post messages to slack: #sim-transactions-test
      {status, resp} = HTTPoison.post(
        System.get_env("SLACK_WEBHOOK_URL"),
        Jason.encode!(payload),
        [
          {"Content-type", "application/json"},
        ],
        recv_timeout: 10000
      )

      # check the status
      case status do
        :ok -> true
        :error -> {:error, "There was an error: #{resp}"}
      end
    catch
      _type, _reason ->
        "There was an error sending a message to Slack"
    end

    {:ok, result}
  end
end

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
    "send_slack_message",
    "join_string"
  ]

  @doc """
    The list of functions allowed to be used for dynamic execution
  """
  def allowed_functions() do
    @whitelist
  end

  # TODO: Here we add the modules that will be executed or attempted with a case
  def execute(%{ "payload" => _ ,"meta_data" => meta_data, "params" => params} = data) do
    case meta_data["func_string"] do
      "add" ->
        LeafNode.Core.Functions.Add.compute(params)
      "subtract" ->
        LeafNode.Core.Functions.Subtract.compute(params)
      "multiply" ->
        LeafNode.Core.Functions.Multiply.compute(params)
      "divide" ->
        LeafNode.Core.Functions.Divide.compute(params)
      "value" ->
        LeafNode.Core.Functions.Value.compute(params)
      "ref" ->
        LeafNode.Core.Functions.Ref.compute(params)
      "equals" ->
        LeafNode.Core.Functions.Equals.compute(params)
      "not_equals" ->
        LeafNode.Core.Functions.NotEquals.compute(params)
      "less_than" ->
        LeafNode.Core.Functions.LessThan.compute(params)
      "greater_than" ->
        LeafNode.Core.Functions.GreaterThan.compute(params)
      "input" ->
        LeafNode.Core.Functions.Input.compute(params)
      "get_map_val" ->
        LeafNode.Core.Functions.GetMapVal.compute(params)
      "send_slack_message" ->
        LeafNode.Core.Functions.SendSlackMessage.compute(params)
      "join_string" ->
        LeafNode.Core.Functions.JoinString.compute(params)
      _ ->
        "Function does not exist"
    end
  end

  @doc """
    Add two values together
  """
  # TODO: Make sure to look at the types here that both are NUMBERS
  def add(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) == 2 do
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

  # This is a fallback catch all if the above fails
  def add(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Minus two values from eachother
  """
  # TODO: Make sure to look at the types here that both are NUMBERS
  def subtract(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    result = try do
      Enum.at(params, 0) - Enum.at(params, 1)
    catch
      _type, _reason ->
        "There was an error subtracting values. Confirm values are numbers and/or correctly referenced"
    end

    {:ok, result}
  end

@doc """
    Minus two values from eachother
  """
  # TODO: Make sure to look at the types here that both are NUMBERS
  def subtract(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    result = try do
      Enum.at(params, 0) - Enum.at(params, 1)
    catch
      _type, _reason ->
        "There was an error subtracting values. Confirm values are numbers and/or correctly referenced"
    end

    {:ok, result}
  end

  # This is a fallback catch all if the above fails
  def subtract(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}


  @doc """
   Join Two strings together
  """
  # TODO: Make sure to look at the types here that both are NUMBERS
  def join_string(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    result = try do
      "#{Enum.at(params, 0)}#{Enum.at(params, 1)}"
    catch
      _type, _reason ->
        "There was an error joining string values. Confirm values are of correct type  being passed through i.e \"strings\" need to be used "
    end

    {:ok, result}
  end

  # This is a fallback catch all if the above fails
  def join_string(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Multiply two values together
  """
  # TODO: Make sure to look at the types here that both are NUMBERS
  def multiply(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    result = try do
      Enum.at(params, 0) * Enum.at(params, 1)
    catch
      _type, _reason ->
        "There was an error multiplying values. Confirm values are numbers and/or correctly referenced"
    end

    {:ok, result}
  end

  # This is a fallback catch all if the above fails
  def multiply(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Divide a value against another
  """
  # TODO: Make sure to look at the types here that both are NUMBERS
  def divide(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    result = try do
      Enum.at(params, 0) / Enum.at(params, 1)
    catch
      _type, _reason ->
        "There was an error dividing values. Confirm values are numbers and/or correctly referenced"
    end

    {:ok, result}
  end

  # This is a fallback catch all if the above fails
  def divide(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Return the passed value
  """
  # TODO: Make sure to look at the types here is either STRING | BOOLEAN | NUMBER
  def value(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 1 do
    {:ok, Enum.at(params, 0)}
  end

  # This is a fallback catch all if the above fails
  def value(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 1 param"}

  @doc """
    Reference or get data from another paragraph
  """
  # TODO: Make sure to look at the types here is a STRING
  def ref(%{ "payload" => _ ,"meta_data" => meta_data, "params" => params}) when length(params) === 1 do

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

  # This is a fallback catch all if the above fails
  def ref(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 1 param"}

  @doc """
    Get a value from a map
  """
  # TODO: Make sure to look at the types here is a MAP and a STRING
  def get_map_val(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    payload_input = Enum.at(params, 0)
    location_param = Enum.at(params, 1)

    result = try do
      Kernel.get_in(payload_input, String.split(location_param, "."))
    rescue _ ->
      %{}
    end
    {:ok, result}
  end

  # This is a fallback catch all if the above fails
  def get_map_val(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Check if one value equals another
  """
  # TODO: Make sure to look at the types here that both NEED TO BE A PRIMITIVE OR A REF
  def equals(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    {:ok, Enum.at(params, 0) === Enum.at(params, 1)}
  end

  # This is a fallback catch all if the above fails
  def equals(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Check if one value is not equal to another
  """
  # TODO: Make sure to look at the types here that both NEED TO BE A PRIMITIVE OR A REF
  def not_equals(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    {:ok, Enum.at(params, 0) !== Enum.at(params, 1)}
  end

  # This is a fallback catch all if the above fails
  def not_equals(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Check if one value is less than another
  """
  # TODO: Make sure to look at the types here that both NEED TO BE NUMBERS
  def less_than(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    {:ok, Enum.at(params, 0) < Enum.at(params, 1)}
  end

  # This is a fallback catch all if the above fails
  def less_than(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Check if one value is greater than another
  """
  def greater_than(%{ "payload" => _ ,"meta_data" => _meta_data, "params" => params}) when length(params) === 2 do
    {:ok, Enum.at(params, 0) > Enum.at(params, 1)}
  end

  # This is a fallback catch all if the above fails
  def greater_than(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 2 params"}

  @doc """
    Get the input value passed
  """
  # TODO: Make sure to look at the types here are a MAP
  def input(%{ "payload" => payload ,"meta_data" => _meta_data, "params" => params}) do
    {:ok, payload}
  end

  @doc """
    Send to slack channel
  """
  # TODO: Make sure to look at the types here that IS A STRING
  def send_slack_message(%{ "payload" => _payload ,"meta_data" => _meta_data, "params" => params}) when length(params) === 1 do
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

  # This is a fallback catch all if the above fails
  def send_slack_message(_), do: {:ok, "There was a problem. Verify the input data being passed to the function that it matches 1 param"}
end

#TODO: Consider moving the functions in separate modules
#TODO: Another function guard for extra param being a boolean

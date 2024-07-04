defmodule LeafNode.Servers.TriggerAugmentation do
  @moduledoc """
    Used to hold all of the functions that will be used for AI augmentation of input data
  """
  alias LeafNode

  @doc """
    Query AI with the
  """
  def query_ai(status, payload, %{value: augment_value, enabled: enabled} = _augment, node) when status === :ok do
    # Check if enabled to run
    if enabled do
      {status, resp} = LeafNode.Integrations.OpenAi.Gpt.prompt(payload, augment_value)

      decoded_resp = Jason.decode!(resp)
      case status do
        :ok ->
          {:ok, add_log_to_resp(decoded_resp, LeafNode.log_result(node, payload, decoded_resp, true))}
        _ ->
          {:error, add_log_to_resp(decoded_resp, LeafNode.log_result(node, payload, decoded_resp, false))}
      end
    else
      # TODO: change this if not enabled
      {:error, %{}}
    end
  end
  def query_ai(_status, _payload, _augment, _node) do
    {:error, "There was an error, unable to query AI"}
   end

   # Add the log to the response to have the user debug if needed
   defp add_log_to_resp(resp, log) do
     Map.put(resp, "log_id", log)
   end
end

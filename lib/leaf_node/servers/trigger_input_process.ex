defmodule LeafNode.Servers.TriggerInputProcess do
  @moduledoc """
    Used to hold all of the functions that will be used for AI input process of input data
  """
  alias LeafNode

  @doc """
    Query AI with the
  """
  def query_ai(payload, data)do
    {status, resp} = LeafNode.Integrations.OpenAi.Gpt.prompt(payload.req["message"], data, :node)

    case status do
      :ok ->
        {:ok, resp}
      _ ->
        {:error, "There was an error, unable to query AI - Unable to get a valid response"}
    end
  end
  def query_ai(_status, _payload, _, _node) do
    {:error, "There was an error, unable to query AI"}
   end

   # Add the log to the response to have the user debug if needed
   defp add_log_to_resp(resp, log) do
     Map.put(resp, "log_id", log)
   end
end

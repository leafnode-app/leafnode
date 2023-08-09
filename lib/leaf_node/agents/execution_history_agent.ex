defmodule LeafNode.Agents.ExecutionHistoryAgent do
  use Agent

  @doc """
    Initialize the agent with a unique name we can then get by the process id
  """
  def start_link(id) do
    # we set the inital value of the state to be empty map - we dont care of order
    Agent.start_link(fn -> %{} end, name: get_agent_name(id))
  end

  @doc """
    Get all the state data for the specific agent by id and its history
  """
  def get_all(id) do
    Agent.get(get_agent_name(id), fn data -> {:ok, data} end)
  end

  @doc """
    Get specific set of data by key in map of data that was stored from execution
  """
  def get_by_key(id, key) do
    Agent.get(get_agent_name(id), fn data ->
      result = Map.get(data, key)
      case result do
        nil -> {:error, "There was an error getting data"}
        _ ->
          {:ok, result}
      end
    end)
  end

  @doc """
    Add a new key and data to the agent state
  """
  def set_new_key(id, key, data) do
    Agent.update(get_agent_name(id), fn stored_data -> Map.put_new(stored_data, key, data) end)
  end

  #TODO: Add a way to remove from the state? Might not be needed as it is removed at run time

  #NOTE: adding the option to stop the agent server but its linked so can be ignored, this is if we
  # need to do it manually
  def stop(id) do
    Agent.stop(get_agent_name(id))
  end


  # helper method to generate a uniqte name for the agent
  defp get_agent_name(id) do
    String.to_atom(Atom.to_string(__MODULE__) <> "_" <> id)
  end
end

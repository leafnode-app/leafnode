defmodule LeafNode.Servers.ExecutionHistoryServer do
  use GenServer

  @doc """
    Initialize the agent with a unique name we can then get by the process id
  """
  def start_link(id) do
    GenServer.start_link(__MODULE__, %{ "id" => id }, name: String.to_atom("history_"<>id))
  end

  @doc """
    Set the intial state
  """
  def init(state) do
    {:ok, state}
  end

  def handle_call(:get_history, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_history, key, value}, _from, state) do
    updated_state = Map.put(state, key, value)
    {:reply, updated_state, updated_state}
  end

  def handle_call(:flush_history, _from, _state) do
    flushed_state = %{}
    {:reply, flushed_state, flushed_state}
  end

  def handle_call({:get_by_key, key}, _from, state) do
    {:reply, get_by_key(key, state), state}
  end

  @doc """
    Get specific set of data by key in map of data that was stored from execution
  """
  defp get_by_key(key, state) do
    result = Map.get(state, key)
      case result do
        nil -> {:error, "There was an error getting data"}
        _ ->
          {:ok, result}
      end
  end
end

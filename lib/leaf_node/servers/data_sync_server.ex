defmodule LeafNode.Servers.DataSyncServer do
  @moduledoc """
    This server will run on startup of the system and its job is to make sure
    the data in mem vs the data on disk is in sync. If not we need to refresh
    the data in memeory with that on disk. Note That disk will always be source of truth
  """
  use GenServer
  require Logger

  @timeout 10_000
  @doc """
    Start the server
  """
  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args, [name: __MODULE__])
  end

  @doc """
    Initialize the scheduler process
  """
  # TODO: Initialize and dont wait for the send after as the system wont be in sync initially
  def init(state) do
    initial_state = %{}
    schedule_work(state.interval)
    {:ok, state}
  end

  @doc """
    Handle the process event scheduler
  """
  def handle_info(:work, state) do
    {mem_status, mem_resp} = GenServer.call(LeafNode.Servers.MemoryServer, :get_hash, @timeout)
    {disk_status, disk_resp} = GenServer.call(LeafNode.Servers.DiskServer, :get_hash, @timeout)

    case disk_status do
      :ok ->
        # check if the data is the same, if not, we sync
        if mem_resp !== disk_resp do
          Logger.info("Server: LeafNode.Servers.DataSyncServer. Event: work. Func: copy_to_ets")
          LeafNode.Core.Dets.copy_to_ets(:documents)
        end
      _ ->
        Logger.warn("Disk status fetch error: #{disk_status}. Resp: #{disk_resp}")
    end

    schedule_work(state.interval)
    {:noreply, state}
  end

  # send after a certain time
  defp schedule_work(interval) do
    Process.send_after(self(), :work, interval) # Schedule work to be done in 10 seconds
  end
end

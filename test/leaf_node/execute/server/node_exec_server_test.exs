defmodule LeafNode.Execute.Server.NodeExecutionServerTest do
  use ExUnit.Case
  alias LeafNode.Execute.Server.NodeExecutionServer

  test "set and get execution logs" do
    {:ok, pid} = NodeExecutionServer.start([])

    :ok = GenServer.call(pid, {:set_exec_log, "log1"})
    :ok = GenServer.call(pid, {:set_exec_log, "log2"})
    logs = GenServer.call(pid, :get_exec_logs)
    assert logs == ["log2", "log1"]
  end
end

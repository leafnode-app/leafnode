defmodule LeafNode.Execute.NodeTest do
  use LeafNodeWeb.ConnCase
  alias LeafNode.Execute.Server.NodeExecutionServer

  # Constants
  @node %{
    "func" => "get",
    "id" => "beer",
    "input" => [
      %{
        "type" => "value",
        "value" => "https://random-data-api.com/api/v2/beers"
      }
    ],
    "meta_data" => %{},
    "module" => "Elixir.LeafNode.Nodes.Http",
    "name" => "beers fetch",
    "test_input" => "https://random-data-api.com/api/v2/banks",
    "timeout" => 20000
  }

  @example_process %LeafNode.Structs.Process{
    id: "b417fe41-8fa9-4cb7-8327-326fbd42266c",
    name: "test example here",
    description: "Test example",
    restricted: false,
    nodes: [
      %{
        "exit_node" => "entry_node",
        "id" => "entry_node",
        "input" => %{},
        "name" => "entry_node",
        "test_input" => "world"
      }
    ]
  }

  test "execute_node" do
    file_path = String.to_charlist("./execute_node_test.dets")
    assert LeafNode.Core.Dets.open_table(:test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === :test
    assert LeafNode.Core.Dets.insert(:test, Map.get(@example_process, :id), @example_process) === :ok

    result = {"ok",
    %{
      "logs" => %{
        "entry_node" => %{
          "exit_node" => "entry_node",
          "id" => "entry_node",
          "input" => %{},
          "name" => "entry_node",
          "result_output" => %{"data" => "No test input found on node"}
        }
      }
    }}
    assert LeafNode.Execute.Node.execute_node("b417fe41-8fa9-4cb7-8327-326fbd42266c", "entry_node", :test) === result
    File.rm("./execute_node_test.dets")
  end

  test "set_process_run_state" do
    {:ok, pid} = NodeExecutionServer.start([])
    assert LeafNode.Execute.Node.set_process_run_state(pid, @node, "output_data") === :ok
  end

  test "exec_node_test" do
    {:ok, pid} = NodeExecutionServer.start([])
    assert LeafNode.Execute.Node.exec_node_test(@node, pid) === :ok
  end
end

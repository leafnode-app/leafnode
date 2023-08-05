defmodule LeafNode.Execute.ProcessTest do
  use LeafNodeWeb.ConnCase

  # Constants
  @example_process %LeafNode.Structs.Process{
    id: "b417fe41-8fa9-4cb7-8327-326fbd42266c",
    name: "test example here",
    description: "Test example",
    exit_node: "input_node",
    restricted: false,
    nodes: []
  }

  test "execute_process" do
    file_path = String.to_charlist("./execute_process_test.dets")
    assert LeafNode.Core.Dets.open_table(:test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === :test
    assert LeafNode.Core.Dets.insert(:test, Map.get(@example_process, :id), @example_process) === :ok

    result = {:ok,
      %{
        "logs" => %{
          "input_node" => %{
            "exit_node" => "input_node",
            "id" => "input_node",
            "input" => %{"test" => "data"},
            "name" => "input_node",
            "result_output" => %{
              "data" => %{"test" => "data"}
            }
          }
        },
        "output" => %{"data" => %{"test" => "data"}}
      }}

    assert LeafNode.Execute.Process.init_execute_process("b417fe41-8fa9-4cb7-8327-326fbd42266c", %{ "test" => "data"}, false, :test) === result
    File.rm("./execute_process_test.dets")
  end
end

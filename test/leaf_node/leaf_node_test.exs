defmodule LeafNode.LeafNodeTest do
  use LeafNodeWeb.ConnCase

  @node_example %{
    "func" => "print",
    "id" => "node-1",
    "input" => [
      %{
        "get_in" => [
          "data",
          "one"
        ],
        "type" => "ref_key",
        "value" => "entry_node"
      }
    ],
    "meta_data" => %{},
    "module" => "Elixir.LeafNode.Core.Lib",
    "name" => "node-1",
    "timeout" => 20000
  }

  @nodes_list_example [
    %{
        "func" => "print",
        "id" => "node-1",
        "input" => [
            %{
                "get_in" => [
                    "data",
                    "value"
                ],
                "type" => "ref_key",
                "value" => "entry_node"
            }
        ],
        "meta_data" => %{},
        "module" => "Elixir.LeafNode.Core.Lib",
        "name" => "node-1",
        "test_input" => %{
            "value" => "SOME TEST VALUE node-1"
        },
        "timeout" => 20000
    },
    %{
        "func" => "error",
        "id" => "node-error",
        "input" => [
            %{
                "type" => "value",
                "value" => "THIS IS SOME ERROR!"
            }
        ],
        "meta_data" => %{},
        "module" => "Elixir.LeafNode.Core.Lib",
        "name" => "node-erorr",
        "test_input" => "SOME EXAMPLE VALUE TEST DATA node-error",
        "timeout" => 20000
    },
    %{
        "func" => "print",
        "id" => "node-2",
        "input" => [
            %{
                "type" => "value",
                "value" => "I AM PRINGING"
            }
        ],
        "meta_data" => %{},
        "module" => "Elixir.LeafNode.Core.Lib",
        "name" => "node-2",
        "test_input" => "THIS IS SOME TEST INPUT node-2",
        "timeout" => 20000
    }
  ]

  @execution_log_example %{
    "node-1" => %{
      "id" => "node-1",
      "input" => [
        %{
          "get_in" => ["data", "value"],
          "type" => "ref_key",
          "value" => "entry_node"
        }
      ],
      "name" => "node-1",
      "result_output" => %{"data" => nil}
    },
    "node-2" => %{
      "id" => "node-2",
      "input" => [%{"type" => "value", "value" => "I AM PRINGING"}],
      "name" => "node-2",
      "result_output" => %{"data" => "I AM PRINGING"}
    },
    "node-error" => %{
      "id" => "node-error",
      "input" => [%{"type" => "value", "value" => "THIS IS SOME ERROR!"}],
      "name" => "node-erorr",
      "result_output" => %{
        "data" => %{
          "error" => %{"message" => "THIS IS SOME ERROR!", "meta_data" => "{}"}
        }
      }
    }
  }

  test "generate_result_log" do
    result = %{
      "id" => @node_example["id"],
      "name" => @node_example["name"],
      "input" => @node_example["input"],
      "result_output" => %{
        "data" => "result"
      }
    }

    assert LeafNode.generate_result_log(@node_example, %{"data" => "result"}) === result
  end

  test "is_entry_node?" do
    assert LeafNode.is_entry_node?(@node_example) === false
  end

  test "init_entry_node_input" do
    entry_node = @nodes_list_example |> List.first()
    payload = %{ "test" => "input" }
    result = Map.put(entry_node, "input", payload)
    assert LeafNode.init_entry_node_input(entry_node, payload) === result
  end
end

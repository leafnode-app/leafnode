defmodule LeafNode.Core.EtsTest do
  use LeafNodeWeb.ConnCase

  @tables %{
    "config" => :config,
    "node_processes" => :node_processes
  }
  @ets_test :ets_test

  test "get_system_tables" do
    assert LeafNode.Core.Ets.get_system_tables() === @tables
  end

  test "create_table" do
    assert LeafNode.Core.Ets.create_table(@ets_test, [:set, :named_table, :public]) === @ets_test
  end

  test "insert" do
    assert LeafNode.Core.Ets.create_table(@ets_test, [:set, :named_table, :public]) === @ets_test
    assert LeafNode.Core.Ets.insert(@ets_test, "key", %{"id" => "item_value"}) === true
  end

  test "get_by_key" do
    assert LeafNode.Core.Ets.create_table(@ets_test, [:set, :named_table, :public]) === @ets_test
    assert LeafNode.Core.Ets.insert(@ets_test, "key", %{"id" => "item_value"}) === true
    assert LeafNode.Core.Ets.get_by_key(@ets_test, "key") === {:ok, %{"id" => "item_value"}}
  end

  test "get_all - table doesnt exist" do
    assert LeafNode.Core.Ets.create_table(@ets_test, [:set, :named_table, :public]) === @ets_test
    assert LeafNode.Core.Ets.insert(@ets_test, "item1", %{"id" => "item_value1"}) === true
    assert LeafNode.Core.Ets.insert(@ets_test, "item2", %{"id" => "item_value2"}) === true
    assert LeafNode.Core.Ets.get_all(@ets_test) ===
      {:ok,
        [
          item2: %{"id" => "item_value2"},
          item1: %{"id" => "item_value1"}
        ]
      }
      # Note: The order matters on the response here - last added is first returned
  end

  test "delete_by_key" do
    assert LeafNode.Core.Ets.create_table(@ets_test, [:set, :named_table, :public]) === @ets_test
    assert LeafNode.Core.Ets.insert(@ets_test, "key", %{"id" => "item_value"}) === true
    assert LeafNode.Core.Ets.delete_by_key(@ets_test, "key") === true
  end

  test "table_exists" do
    table = Atom.to_string(@ets_test)
    non_existent_table = "non_existent_table"
    assert LeafNode.Core.Ets.create_table(@ets_test, [:set, :named_table, :public]) === @ets_test
    assert LeafNode.Core.Ets.table_exists?(table) === true
    assert LeafNode.Core.Ets.table_exists?(non_existent_table) === false
  end

end

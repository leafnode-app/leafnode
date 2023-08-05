defmodule LeafNode.Core.DetsTest do
  use LeafNodeWeb.ConnCase

  @tables %{
    "config" => :config,
    "node_processes" => :node_processes,
    "access_keys" => :access_keys,
    "documents" => :documents
  }

  @dets_test :dets_test

  @test_table_path './dets_test.dets'

  def open_table do
    assert LeafNode.Core.Dets.open_table(@dets_test, [{:file, @test_table_path}, {:type, :set}]) === @dets_test
  end

  test "get_system_tables" do
    assert LeafNode.Core.Dets.get_system_tables() === @tables
  end

  test "create_table" do
    open_table()
    File.rm(@test_table_path)
  end

  test "insert" do
    open_table()
    assert LeafNode.Core.Dets.insert(@dets_test, "key", %{"id" => "item_value"}) === :ok
    File.rm(@test_table_path)
  end

  test "get_by_key" do
    open_table()
    assert LeafNode.Core.Dets.insert(@dets_test, "key", %{"id" => "item_value"}) === :ok
    assert LeafNode.Core.Dets.get_by_key(@dets_test, "key") === {:ok, %{"id" => "item_value"}}
    File.rm(@test_table_path)
  end

  test "get_all - table doesnt exist" do
    open_table()
    assert LeafNode.Core.Dets.insert(@dets_test, "item1", %{"id" => "item_value1"}) === :ok
    assert LeafNode.Core.Dets.insert(@dets_test, "item2", %{"id" => "item_value2"}) === :ok
    assert LeafNode.Core.Dets.get_all(@dets_test) ===
      {:ok,
        %{
        "item1" => %{"id" => "item_value1"},
        "item2" => %{"id" => "item_value2"}
        }
      }
    File.rm(@test_table_path)
  end

  test "delete_by_key" do
    open_table()
    assert LeafNode.Core.Dets.insert(@dets_test, "key", %{"id" => "item_value"}) === :ok
    assert LeafNode.Core.Dets.delete(@dets_test, "key") === :ok
    File.rm(@test_table_path)
  end
end

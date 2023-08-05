defmodule LeafNode.Core.ProcessTest do
  use LeafNodeWeb.ConnCase

  @process_test :process_test
  @payload %{
    "id" => "1111",
    "name" => "1111",
    "description" => "1111",
    "restricted" => false,
    "exit_node" => "asd",
    "nodes" => [ "asd"]
  }

  test "create_process" do
    file_path = String.to_charlist("./process_test.dets")
    result = {:ok, "Successfully created process"}
    assert LeafNode.Core.Dets.open_table(@process_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @process_test

    assert LeafNode.Core.Process.create_process(@payload, @process_test) === result

    File.rm("./process_test.dets")
  end

  test "edit_process" do
    file_path = String.to_charlist("./process_test.dets")
    result = {:ok, "Successfully updated process"}

    assert LeafNode.Core.Dets.open_table(@process_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @process_test
    assert LeafNode.Core.Process.create_process(@payload, @process_test)

    assert LeafNode.Core.Process.edit_process(Map.get(@payload, "id"), @payload, @process_test) === result

    File.rm("./process_test.dets")
  end

  test "delete_process" do
    file_path = String.to_charlist("./process_test.dets")
    create_result = {:ok, "Successfully created process"}
    remove_result = {:ok, "Successfully removed process"}

    assert LeafNode.Core.Dets.open_table(@process_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @process_test

    assert LeafNode.Core.Process.create_process(@payload, @process_test) === create_result
    assert LeafNode.Core.Process.delete_process(Map.get(@payload, "id"), @process_test) === remove_result

    File.rm("./process_test.dets")
  end

  test "list_processes" do
    file_path = String.to_charlist("./process_test.dets")
    create_result = {:ok, "Successfully created process"}
    list_result = {:ok,
      %{
        "1111" => %{
          description: "1111",
          id: "1111",
          name: "1111",
          nodes: ["asd"],
          exit_node: "asd",
          restricted: false
        }
      }}

    assert LeafNode.Core.Dets.open_table(@process_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @process_test

    assert LeafNode.Core.Process.create_process(@payload, @process_test) === create_result
    assert LeafNode.Core.Process.list_processes(@process_test) === list_result

    File.rm("./process_test.dets")
  end

  test "get_process" do
    file_path = String.to_charlist("./process_test.dets")
    create_result = {:ok, "Successfully created process"}
    get_access_key_result = {:ok,
      %{
        description: "1111",
        id: "1111",
        name: "1111",
        nodes: ["asd"],
        exit_node: "asd",
        restricted: false
      }}

    assert LeafNode.Core.Dets.open_table(@process_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @process_test

    assert LeafNode.Core.Process.create_process(@payload, @process_test) === create_result
    assert LeafNode.Core.Process.get_process(Map.get(@payload, "id"), @process_test) === get_access_key_result

    File.rm("./process_test.dets")
  end
end

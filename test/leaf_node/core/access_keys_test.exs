defmodule LeafNode.Core.AccessKeysTest do
  use LeafNodeWeb.ConnCase

  @access_keys_test :access_keys_test
  @payload %{
    "label" => "access key test",
    "id" => "1111",
    "token" => "access key token",
    "processes" => ["some process"]
  }

  test "create_access_key" do
    file_path = String.to_charlist("./access_keys_test.dets")
    result = {:ok, "Successfully created access key"}

    assert LeafNode.Core.Dets.open_table(@access_keys_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @access_keys_test

    assert LeafNode.Core.AccessKeys.create_access_key(@payload, @access_keys_test) === result

    File.rm("./access_keys_test.dets")
  end

  test "edit_access_key" do
    file_path = String.to_charlist("./access_keys_test.dets")
    result = {:ok, "Successfully updated access key"}

    assert LeafNode.Core.Dets.open_table(@access_keys_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @access_keys_test
    assert LeafNode.Core.AccessKeys.create_access_key(@payload, @access_keys_test)

    assert LeafNode.Core.AccessKeys.edit_access_key(Map.get(@payload, "id"), @payload, @access_keys_test) === result

    File.rm("./access_keys_test.dets")
  end

  test "delete_access_key" do
    file_path = String.to_charlist("./access_keys_test.dets")
    create_result = {:ok, "Successfully created access key"}
    remove_result = {:ok, "Successfully removed access key"}

    assert LeafNode.Core.Dets.open_table(@access_keys_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @access_keys_test

    assert LeafNode.Core.AccessKeys.create_access_key(@payload, @access_keys_test) === create_result
    assert LeafNode.Core.AccessKeys.delete_access_key(Map.get(@payload, "id"), @access_keys_test) === remove_result

    File.rm("./access_keys_test.dets")
  end

  test "list_access_keys" do
    file_path = String.to_charlist("./access_keys_test.dets")
    create_result = {:ok, "Successfully created access key"}
    list_result = {:ok, %{"1111" => %{id: "1111", label: "access key test", processes: ["some process"], token: "access key token"}}}

    assert LeafNode.Core.Dets.open_table(@access_keys_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @access_keys_test

    assert LeafNode.Core.AccessKeys.create_access_key(@payload, @access_keys_test) === create_result
    assert LeafNode.Core.AccessKeys.list_access_keys(@access_keys_test) === list_result

    File.rm("./access_keys_test.dets")
  end

  test "process_by_access_key" do
    file_path = String.to_charlist("./access_keys_test.dets")
    create_result = {:ok, "Successfully created access key"}
    list_result = {:ok, %{"access key token" => ["some process"]}}

    assert LeafNode.Core.Dets.open_table(@access_keys_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @access_keys_test

    assert LeafNode.Core.AccessKeys.create_access_key(@payload, @access_keys_test) === create_result
    assert LeafNode.Core.AccessKeys.process_by_access_key(@access_keys_test) === list_result

    File.rm("./access_keys_test.dets")
  end

  test "get_access_key" do
    file_path = String.to_charlist("./access_keys_test.dets")
    create_result = {:ok, "Successfully created access key"}
    get_access_key_result = {:ok, %{id: "1111", label: "access key test", processes: ["some process"], token: "access key token"}}

    assert LeafNode.Core.Dets.open_table(@access_keys_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @access_keys_test

    assert LeafNode.Core.AccessKeys.create_access_key(@payload, @access_keys_test) === create_result
    assert LeafNode.Core.AccessKeys.get_access_key(Map.get(@payload, "id"), @access_keys_test) === get_access_key_result

    File.rm("./access_keys_test.dets")
  end
end

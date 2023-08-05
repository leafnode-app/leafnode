defmodule LeafNode.Core.ConfigTest do
  use LeafNodeWeb.ConnCase

  @config_test :config_test
  @payload %{
    "label" => "config test",
    "id" => "1111",
    "data" => %{}
  }

  test "create_config" do
    file_path = String.to_charlist("./config_test.dets")
    result ={:ok, "Successfully created config"}

    assert LeafNode.Core.Dets.open_table(@config_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @config_test

    assert LeafNode.Core.Config.create_config(@payload, @config_test) === result

    File.rm("./config_test.dets")
  end

  test "edit_config" do
    file_path = String.to_charlist("./config_test.dets")
    result = {:ok, "Successfully updated config"}

    assert LeafNode.Core.Dets.open_table(@config_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @config_test
    assert LeafNode.Core.Config.create_config(@payload, @config_test)

    assert LeafNode.Core.Config.edit_config(Map.get(@payload, "id"), @payload, @config_test) === result

    File.rm("./config_test.dets")
  end

  test "delete_config" do
    file_path = String.to_charlist("./config_test.dets")
    create_result = {:ok, "Successfully created config"}
    remove_result = {:ok, "Successfully removed config"}

    assert LeafNode.Core.Dets.open_table(@config_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @config_test

    assert LeafNode.Core.Config.create_config(@payload, @config_test) === create_result
    assert LeafNode.Core.Config.delete_config(Map.get(@payload, "id"), @config_test) === remove_result

    File.rm("./config_test.dets")
  end

  test "list_configs" do
    file_path = String.to_charlist("./config_test.dets")
    create_result = {:ok, "Successfully created config"}
    list_result = {:ok, %{"1111" => %{data: %{}, id: "1111", label: "config test"}}}

    assert LeafNode.Core.Dets.open_table(@config_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @config_test

    assert LeafNode.Core.Config.create_config(@payload, @config_test) === create_result
    assert LeafNode.Core.Config.list_configs(@config_test) === list_result

    File.rm("./config_test.dets")
  end

  test "get_config" do
    file_path = String.to_charlist("./config_test.dets")
    create_result = {:ok, "Successfully created config"}
    get_access_key_result = {:ok, %{data: %{}, id: "1111", label: "config test"}}

    assert LeafNode.Core.Dets.open_table(@config_test, [{ :file, file_path }, { :type, :set }, {:auto_save, 60_000}]) === @config_test

    assert LeafNode.Core.Config.create_config(@payload, @config_test) === create_result
    assert LeafNode.Core.Config.get_config(Map.get(@payload, "id"), @config_test) === get_access_key_result

    File.rm("./config_test.dets")
  end
end

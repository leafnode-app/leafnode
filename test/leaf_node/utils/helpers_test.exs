defmodule LeafNode.Utils.HelpersTest do
  use LeafNodeWeb.ConnCase

  test "list_to_map" do
    list = [
      %{"id" => "item1", "data" => "Some data 1"},
      %{"id" => "item2", "data" => "Some data 2"}
    ]

    result = %{
      "item1" => %{"id" => "item1", "data" => "Some data 1"},
      "item2" => %{"id" => "item2", "data" => "Some data 2"}
    }

    assert LeafNode.Utils.Helpers.list_to_map(list, %{}, "id") === result
  end

  test "strings_to_existing_atoms" do
    assert LeafNode.Utils.Helpers.strings_to_existing_atoms(["string"]) === [:string]
  end

  test "http_resp" do
    result = %{
      "success" => true,
      "code" => 200,
      "result" => %{}
    }
    assert LeafNode.Utils.Helpers.http_resp(200, true) === result
  end
end

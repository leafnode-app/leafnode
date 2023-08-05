defmodule LeafNode.Core.LibTest do
  use LeafNodeWeb.ConnCase

  test "error/0" do
    assert LeafNode.Core.Lib.error() === %{"error" => "There was an error"}
  end

  test "error/1" do
    msg = "some error"
    assert LeafNode.Core.Lib.error("some error") ===
      %{
        "error" =>
        %{
          "message" => msg,
          "meta_data" => Jason.encode!(%{})
        }
      }
  end

  test "error/2" do
    payload = %{ "test" => "data"}
    msg = "some error"
    assert LeafNode.Core.Lib.error("some error", payload) ===
      %{
        "error" =>
        %{
          "message" => msg,
          "meta_data" => Jason.encode!(payload)
        }
      }
  end

  test "print" do
    payload = %{ "test" => "data"}
    assert LeafNode.Core.Lib.print(payload) === payload
  end
end

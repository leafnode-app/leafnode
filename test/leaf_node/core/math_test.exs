defmodule LeafNode.Core.MathTest do
  use LeafNodeWeb.ConnCase

  test "add" do
    assert LeafNode.Core.Math.add(12, 2) === 14
  end

  test "subtract" do
    assert LeafNode.Core.Math.subtract(12, 2) === 10
  end

  test "multiply" do
    assert LeafNode.Core.Math.multiply(12, 2) === 24
  end
end

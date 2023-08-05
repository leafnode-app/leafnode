defmodule LeafNode.Core.GptTest do
  use LeafNodeWeb.ConnCase

  @doc """
    This is the module test for GPT, this does do executions so we can check tokens and general usage.
    This is not required generally otherwise and could be removed and shouldnt be here for the sake of
    having tests.
  """
  test "prompt" do
    assert LeafNode.Core.Gpt.prompt("hello") === {:test_response, "world"}
  end
end
